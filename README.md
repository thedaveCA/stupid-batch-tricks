# Stupid Batch Tricks

Collection of Windows Batch scripts written in the 2020s. Some scripts are useful, others are pointless. While batch scripts are _never_ the best solution for many tasks, I've been writing them since the 1990s, and I'm not going to stop now.

## License

_Mozilla Public License Version 2.0_ for the code I've written. Inspiration and code snippets from other sources are noted in the scripts and may override this license.

Summarized: You can use, modify, and distribute this code as long as you include the original license and any attributions.

See the [LICENSE.txt](LICENSE.txt) file for the full text, or visit [https://choosealicense.com/licenses/mpl-2.0/](https://choosealicense.com/licenses/mpl-2.0/).

## Directory Structure

| Directory                   | Description                                               |
|----------------------------|------------------------------------------------------------|
| [/](#main-scripts) | The main scripts that do something "useful".                       |
| [Helpers](#helpers) | Useful batch scripts that can be included in other batch scripts. |
| [Pointless](#pointless) | Pointless stuff that probably shouldn't exist.                |
| [Snippets](#snippets) | Snippets of reusable code                                       |

## Main Scripts

| Filename       | Description                             |
|----------------|-----------------------------------------|
| `cdd.cmd`      | Change drive+directory, or ~ or :keyword |
| `delay.cmd`    | Pause script execution for a defined number of seconds. |

## Helpers

Useful batch scripts that can be included in other batch scripts.

| Filename                          | Description                                                |
|-----------------------------------|------------------------------------------------------------|
| `ANSI.cmd`                        | Detects ANSI support and sets ANSI variables.              |
| `CleanEnvironmentVariables.cmd`   | Removes environment variables by prefix.                   |
| `GetWindowsLanguage.cmd`          | Sets BATCH_WIN_LANGUAGE from the OS language.              |
| `GetWindowsVersion.cmd`           | Sets BATCH_WINVER_* from OS details.                       |
| `TimeStamp.cmd`                   | Generates a unique BATCH_TIMESTAMP from current date/time. |

## Pointless

Scripts that serve no practical purpose.

| Filename       | Description                                                |
|----------------|------------------------------------------------------------|
| `jump.cmd`     | A batch "solution" for the "Jumping Game" problem.         |
| `snake.cmd`    | Robert F Van Etta III 2018's Windows 10 Console Ansi Demo. |

## Snippets

Snippets of reusable code

| Filename       | Description                                                |
|--------------------|--------------------------------------------------------|
| `fileorfolder.cmd` | Check if you have a folder, file, or neither           |
| 'padding.cmd`      | Add padding to, or truncate, a string                  |
