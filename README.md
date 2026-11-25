# Odin Project Template

A minimal project template for the Odin Programming Language with automatic OLS (Odin Language Server) configuration

> [!IMPORTANT]
> This template is linux first and currently only has support for UNIX based systems (to run scripts/setup.sh)
> A windows option may be added later if someone needs it

---

## Requirements

- [Odin](https://odin-lang.org)
- [Odin Language Server](https://github.com/DanielGavin/ols)

For VSCode, you also need to install the [Odin Language Server extension](https://marketplace.visualstudio.com/items?itemName=DanielGavin.ols). The template will also recommend the extension in case you do not have it.

> [!NOTE]
> The setup script will not install Odin or the Odin Language Server
> It only generates an ols.json file that OLS uses as a configuration file

---

## Getting Started

### 1. Creating your project

To create a project you have a few options:

1. You can clone this repository:

```sh
mkdir my-project
cd my-project
git clone https://github.com/TheVolpeDev/odin-template.git .
```

2. Use [this link](https://github.com/new?template_name=odin-template&template_owner=TheVolpeDev)
3. Click "Use this template" in the Github UI

### 2. Configure OLS

You can run the setup script by simply doing `./scripts/setup.sh`

> [!IMPORTANT]
> You may need to make the script executable first, in that case you must first run: `chmod +x scripts/setup.sh`

### 3. Run the example

You can run the example project directly:

```sh
odin run src
```

Alternatively you can run it through VSCode Tasks, there are tasks for Building (debug & release) as well as running

---

## Odin Installation Detection

The setup script uses the following detection order:

1. Explicit path passed as CLI argument
2. `ODIN_ROOT` environment variable
3. `ODIN_HOME` environment variable
4. Odin executable available through PATH
5. Interactive path prompt

The first successful supplied path will be used for the configuration

---

## Formatting

This repository includes an `odinfmt.json` file to provide default formatting settings

Formatting on save is enabled in the VSCode settings.json file

---

## Using Another Editor

This is a VSCode first template, but you can also use other editors.

The generated `ols.json` file is generated to project root, OLS can read and support this in multiple editors, for your specific editor of choice please refer to the [official OLS documentation](https://github.com/DanielGavin/ols).
