import Bluebird = require("bluebird")
import _ = require("lodash")
import cli = require("commander")
import cli_analyze = require("./cli/analyze")
import cli_auth = require("./cli/auth")
import cli_init = require("./cli/init")
import cli_docs = require("./cli/docs")
import cli_version = require("./cli/version")
import logger = require("./logger")

const log = logger.create("cli")

const pkg = require("./../package")

// Note: This only registers for non-worker forked processes
process.on("unhandledRejection", (
  error : NodeJS.ErrnoException | string,
  promise : Bluebird<any>
) => {
  console.log() // next line if spinner
  log.error("unhandled Promise.reject")
  log.error(_.get(error, "stack", error))
  process.exit(1)
})

const no_args = (argv : string[]) : boolean =>
  !argv.slice(2).length

const log_additional_help = () => {
  console.log()
  console.log()
  console.log("  Command specific help:")
  console.log()
  console.log("    {cmd} -h, --help")
  console.log()
}

const sub_modules = () : ferret.CLIModule[] => [
  cli_analyze,
  cli_auth,
  cli_init,
  cli_docs,
  cli_version
]

const bind_sub_module = (cli_sub_mod : ferret.CLIModule) => {
  cli_sub_mod.create(cli)
}

const configure = (argv : string[]) => {
  cli.version(pkg.version)
  _.each(sub_modules(), bind_sub_module)
  cli.on("--help", log_additional_help)
  if (no_args(argv)) cli.outputHelp()
}

const interpret = (argv : string[]) => {
  configure(argv)
  cli.parse(argv)
}

export = { interpret }
