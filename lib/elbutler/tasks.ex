defmodule ElButler.Tasks do
  @wtc_chapter_regex ~r|<dd class="chapters">.*>(?<chapter>[[:digit:]]+)</a>[/\w]|
  @pod_chapter_regex ~r|<a class='chapter-item' href="/Paragon-of-Destruction/(?<chapter_id>[[:digit:]]+).html"><div class='chapter-info'><p class='chapter-name'>(?<chapter>[[:digit:]]+) [\w\s]+</p></div></a>|
  @fod_chapter_regex ~r|/fiction/21188/forge-of-destiny/chapter/(?<chapter_id>[[:digit:]]+)/|
  @hwfm_chapter_regex ~r|/fiction/26294/he-who-fights-with-monsters/chapter/(?<chapter_id>[[:digit:]]+)/|
  @rm_chapter_regex ~r|/fiction/37951/re-monarch/chapter/(?<chapter_id>[[:digit:]]+)/|

  def check_worth_the_candle() do
    check_webfiction(
      "https://archiveofourown.org/works/11478249/chapters/25740126",
      "WtC",
      @wtc_chapter_regex
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

  def check_fod() do
    check_webfiction_index(
      "https://www.royalroad.com/fiction/21188/forge-of-destiny",
      "FoD",
      @fod_chapter_regex,
      "https://www.royalroad.com/fiction/21188/forge-of-destiny/chapter/{chapter_id}/chapter-1"
    )
  end

  def check_hwfm() do
    check_webfiction_index(
      "https://www.royalroad.com/fiction/26294/he-who-fights-with-monsters/",
      "HWFM",
      @hwfm_chapter_regex,
      "https://www.royalroad.com/fiction/26294/he-who-fights-with-monsters/chapter/{chapter_id}/chapter-1-strange-business"
    )
  end

  def check_rm() do
    check_webfiction_index(
      "https://www.royalroad.com/fiction/37951/re-monarch",
      "RM",
      @rm_chapter_regex,
      "https://www.royalroad.com/fiction/37951/re-monarch/chapter/{chapter_id}/1-prologue"
    )
  end

  defp check_webfiction(url, name, chapter_regex) do
    resp = Tesla.get!(url)
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
        send_new_chapter_notification(name, chapter_url_template, chapter_id, chapter_num)

      [chapter_id] ->
        send_new_chapter_notification(name, chapter_url_template, chapter_id)

      _ ->
        ElButler.Notifications.notify_phone("Can't find #{name} chapter number...")
        {:error, "Can't find #{name} chapter number..."}
    end
  end

  defp send_new_chapter_notification(name, chapter_url_template, chapter_id, chapter_num \\ nil) do
    chapter_num = if chapter_num == nil, do: chapter_id, else: chapter_num
    last_chapter_num = last_chapter(name)
    set_last_chapter(name, chapter_num)

    if last_chapter_num > 0 && chapter_num > last_chapter_num do
      new_chapter_url =
        String.replace(
          chapter_url_template,
          "{chapter_id}",
          Integer.to_string(chapter_id)
        )

      ElButler.Notifications.notify_phone("New Chapter of #{name} is in! #{new_chapter_url}")
      {:new_chapters, chapter_num}
    else
      {:no_new_chapters, chapter_num}
    end
  end

  def extract_chapter_data(body, chapter_regex) do
    chapter_data =
      Regex.scan(chapter_regex, body, capture: :all_names)
      |> Enum.map(fn l -> Enum.map(l, fn d -> String.to_integer(d) end) end)
      |> Enum.sort(fn first, second -> Enum.at(first, 0) >= Enum.at(second, 0) end)

    List.first(chapter_data)
  end

  def last_chapter(name) do
    {:ok, table} = :dets.open_file(:chapters, type: :set)
    res = :dets.lookup(table, name)
    :dets.close(:chapters)

    case res do
      [{_name, num}] -> num
      _ -> 0
    end
  end

  def set_last_chapter(name, chapternum) do
    {:ok, table} = :dets.open_file(:chapters, type: :set)
    :dets.insert(table, {name, chapternum})
    :dets.close(:chapters)
  end
end
