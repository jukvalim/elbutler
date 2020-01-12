defmodule ElButler.Tasks do
  @ mol_chapter_regex ~r|Chapters: (?<chapter>[[:digit:]]+) |
  @ wtc_chapter_regex  ~r|Chapters: (?<chapter>[[:digit:]]+)[/\w]|

  def check_mother_of_learning(old_chapters_count) when is_integer(old_chapters_count) do
    check_webfiction(
      "https://www.fictionpress.com/s/2961893/1/Mother-of-Learning",
      "MoL",
      old_chapters_count,
      @mol_chapter_regex
      )
  end

  def check_worth_the_candle(old_chapters_count) when is_integer(old_chapters_count) do
    check_webfiction(
      "https://archiveofourown.org/works/11478249/chapters/25740126",
      "WtC",
      old_chapters_count,
      @wtc_chapter_regex
      )
  end

  defp check_webfiction(url, name, old_chapters_count, chapter_regex) do
    resp = HTTPoison.get!(url)
    newest_chapter = Regex.run(chapter_regex, resp.body, capture: :all_but_first)

    case newest_chapter do
      [chapter_num] ->
        chapter_num = String.to_integer(chapter_num)
        if chapter_num > old_chapters_count do
          ElButler.Notifications.notify("New Chapter of #{ name } is in!")
          {:new_chapters, chapter_num }
        else
          {:no_new_chapters, chapter_num}
        end
      _ ->
        ElButler.Notifications.notify("Can't find #{ name } chapter number...")
        {:error, "Can't find #{ name } chapter number..."}
    end
  end
end
