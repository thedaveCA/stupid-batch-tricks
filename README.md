# Stupid Batch Tricks

Collection of Windows Batch scripts written in the 2020s. Some scripts are useful, others are pointless. While batch scripts are _never_ the best solution for many tasks, I've been writing them since the 1990s, and I'm not going to stop now.

## Directory Structure

| Directory                   | Description                                               |
|----------------------------|------------------------------------------------------------|
| [/](#main-scripts) | The main scripts that do something "useful".                       |
| [Helpers](#helpers) | Useful batch scripts that can be included in other batch scripts. |
| [Pointless](#pointless) | Pointless stuff that probably shouldn't exist.                |

## Main Scripts

| Filename       | Description                             |
|----------------|-----------------------------------------|
| `~.cmd`        | Change directory to the user's home.    |
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
