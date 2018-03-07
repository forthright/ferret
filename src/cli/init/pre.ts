import fs = require("fs")
import path = require("path")
import inquirer = require("inquirer")
import Bluebird = require("bluebird")

// HACK: type defs not right?
const fs_writeFile : any = Bluebird.promisify(fs.writeFile)

const check_for_existing_config = (
  config : ferret.YMLConfig
) : Bluebird<ferret.YMLConfig> => {
  const ferret_yml_path = path.join(process.cwd(), ".ferret.yml")

  if (fs.existsSync(ferret_yml_path)) {
    return (inquirer as any).prompt([
      {
        default: true,
        message: "Found an existing .ferret.yml. OK to overwrite?",
        name: "ok_to_overwrite",
        type: "confirm"
      }
    ]).then((answers : any) => {
      if (answers.ok_to_overwrite) {
        return Bluebird.resolve(config)
      } else {
        return Bluebird.resolve(process.exit(0))
      }
    })
  } else {
    return Bluebird.resolve(config)
  }
}

const check_for_existing_package_json = (
  config : ferret.YMLConfig
) : Bluebird<ferret.YMLConfig> => {
  const pkg_json_path = path.join(process.cwd(), "package.json")

  if (fs.existsSync(pkg_json_path)) return Bluebird.resolve(config)

  const pkg_json_shell = {
    description: "Tracks any Node.js based dependencies for ferret.",
    name: "ferret-project-dependency-config",
    private: true
  }

  const file_data = new Buffer(JSON.stringify(pkg_json_shell, null, "  "))

  return fs_writeFile(pkg_json_path, file_data)
    .then((err : NodeJS.ErrnoException) =>
      err ?
        Bluebird.reject(err) :
        Bluebird.resolve(config))
}

export = {
  init: (config : ferret.YMLConfig) =>
    check_for_existing_config(config)
    .then(check_for_existing_package_json)
}
