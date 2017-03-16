## Contribute to translations ##

Please fork this repository and sync with master if you haven't done so.

1. If you you're going to add support for a new language run `./Message.sh lang_name` (e.g. `./Message.sh fr` to add support for French)
2. If you want to refine translation of already supported language run `./Message.sh` before modifying `.po` files to ensure they have latest translatable strings.
3. Open .po` file in any text redactor or any Language Tool(e.g. Qt Linguist).
4. Fill in `msgstr` with translated strings
5. Check if there are any `fuzzy` translations that need your attention.
6. Save
7. Add a git commit and send a pull request.
