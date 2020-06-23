defmodule ElButler.Tasks do
  @wtc_chapter_regex ~r|<dd class="chapters">.*>(?<chapter>[[:digit:]]+)</a>[/\w]|
  @hoc_chapter_regex ~r|/fiction/32502/heart-of-cultivation/chapter/(?<chapter_id>[[:digit:]]+)/(?<chapter>[[:digit:]]+)-|
  @pod_chapter_regex ~r|<dd> <a style="" href="(?<chapter_id>[[:digit:]]+).html">(?<chapter>[[:digit:]]+) \w+</a></dd>|

  def check_worth_the_candle() do
    check_webfiction(
      "https://archiveofourown.org/works/11478249/chapters/25740126",
      "WtC",
      @wtc_chapter_regex
    )
  end

  def check_hoc() do
    check_webfiction_index(
      "https://www.royalroad.com/fiction/32502/heart-of-cultivation",
      "HoC",
      @hoc_chapter_regex,
      "https://www.royalroad.com/fiction/32502/heart-of-cultivation/chapter/{chapter_id}/1-a-fallen-prodigy-1"
    )
  end

  def check_pod() do
    check_webfiction_index(
      "https://www.wuxiaworld.co/Paragon-of-Destruction/",
      "PoD",
      @pod_chapter_regex,
      "https://www.wuxiaworld.co/Paragon-of-Destruction/{chapter_id}.html"
    )
  end

  defp check_webfiction(url, name, chapter_regex) do
    resp = Tesla.get!(url)
    IO.puts(resp.body)
    newest_chapter = Regex.run(chapter_regex, resp.body, capture: :all_but_first)

    old_chapters_count = last_chapter(name)

    case newest_chapter do
      [chapter_num] ->
        chapter_num = String.to_integer(chapter_num)
        set_last_chapter(name, chapter_num)

        if old_chapters_count > 0 && chapter_num > old_chapters_count do
          ElButler.Notifications.notify_phone("New Chapter of #{name} is in!")
          {:new_chapters, chapter_num}
        else
          {:no_new_chapters, chapter_num}
        end

      _ ->
        ElButler.Notifications.notify_phone("Can't find #{name} chapter number...")
        {:error, "Can't find #{name} chapter number..."}
    end
  end

  defp check_webfiction_index(url, name, chapter_regex, chapter_url_template) do
    resp = Tesla.get!(url)
    cd = extract_chapter_data(resp.body, chapter_regex)

    case cd do
      [chapter_num, chapter_id] ->
        old_chapters_count = last_chapter(name)
        set_last_chapter(name, chapter_num)

        if old_chapters_count > 0 && chapter_num > old_chapters_count do
          new_chapter_url =
            String.replace(
              chapter_url_template,
              "{chapter_id}",
              chapter_id
            )

          ElButler.Notifications.notify_phone("New Chapter of #{name} is in! #{new_chapter_url}")
          {:new_chapters, chapter_num}
        else
          {:no_new_chapters, chapter_num}
        end

      _ ->
        ElButler.Notifications.notify_phone("Can't find #{name} chapter number...")
        {:error, "Can't find #{name} chapter number..."}
    end
  end

  def extract_chapter_data(body, chapter_regex) do
    chapter_data =
      Regex.scan(chapter_regex, body, capture: :all_names)
      |> Enum.map(fn l -> [String.to_integer(Enum.at(l, 0)), Enum.at(l, 1)] end)
      |> Enum.sort(fn first, second -> Enum.at(first, 0) >= Enum.at(second, 0) end)

    List.first(chapter_data)
  end

  def last_chapter(name) do
    {:ok, table} = :dets.open_file(:chapters, type: :set)
    res = :dets.lookup(table, name)

    case res do
      [{_name, num}] -> num
      _ -> 0
    end
  end

  def set_last_chapter(name, chapternum) do
    {:ok, table} = :dets.open_file(:chapters, type: :set)
    :dets.insert(table, {name, chapternum})
  end
end
