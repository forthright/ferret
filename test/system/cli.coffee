path = require "path"
_ = require "lodash"
yml = require "js-yaml"
fs = require "fs"
Bluebird = require "bluebird"
chai = require "chai"
rimraf = require "rimraf"
cli = require "./../helpers/system"
issues_snippets = require "./../fixtures/issues-snippets"
issues_combined = require "./../fixtures/issues-combined"
issues_not_combined = require "./../fixtures/issues-not-combined"
expect = chai.expect

CWD = process.cwd()
SYSTEM_TESTS = path.join(
  __dirname, "..", "..", "test", "fixtures", "system")
SYNC_DIR  = path.resolve(path.join(SYSTEM_TESTS, "sync"))
ASYNC_DIR = path.resolve(path.join(SYSTEM_TESTS, "async"))
CMB_FILES_DIR = path.resolve(path.join(SYSTEM_TESTS, "combine_files"))
CLI_INIT_EMPTY_DIR = path.join SYSTEM_TESTS, "cli_init_empty"
CLI_INIT_IGNORES_DIR = path.join SYSTEM_TESTS, "cli_init_ignores"
CLI_INIT_LANGS_DIR = path.join SYSTEM_TESTS, "cli_init_langs"
PLUGIN_CHECK_DIR = path.join SYSTEM_TESTS, "plugin_check"
SNIPPET_DIR = path.join SYSTEM_TESTS, "snippet"
FILTER_IGNORE_DIR = path.join SYSTEM_TESTS, "filtering_ignore"
FILTER_ALLOW_DIR = path.join SYSTEM_TESTS, "filtering_allow"
FILTER_ALLOW_DIR_VIA_CLI_ARGS = path
  .join SYSTEM_TESTS, "filtering_allow_via_cli_args"
LOGGING_DIR = path.join SYSTEM_TESTS, "logging"
SPAWN_DIR = path.join SYSTEM_TESTS, "spawn"
SPAWN_STDERR_DIR = path.join SYSTEM_TESTS, "spawn_stderr"
LOGGING_DIR = path.join SYSTEM_TESTS, "logging"

press =
  ENTER: '\x0D'
  SPACE: '\x20'
  UP: '\x1B\x5B\x41'
  DOWN: '\x1B\x5B\x42'

describe "cli blackbox testing", ->
  afterEach -> process.chdir CWD

  it "can list help", (done) ->
    process.chdir SYNC_DIR

    cli.exec "-h", (stdout) ->
      expect(stdout).to.match /Usage\: vile \[options\] \[command\]/i
      process.chdir CWD
      done()

  describe "auth", ->
    beforeEach -> process.chdir SYNC_DIR

    it "just logs info about creating an account", (done) ->
      cli.exec "auth", (stdout) ->
        expect(stdout).to.match /To authenticate, first go to/i
        expect(stdout).to.match /then:/i
        expect(stdout).to.match /vile p \-u/i
        process.chdir CWD
        done()

  describe "init", ->
    describe "with an empty, fresh project", ->
      beforeEach ->
        process.chdir CLI_INIT_EMPTY_DIR

      afterEach (done) ->
        rimraf CLI_INIT_EMPTY_DIR + "/{.vile.yml,*}", (err) ->
          throw err if err
          fs.writeFileSync(
            path.join(CLI_INIT_EMPTY_DIR, ".keep"), '\n', "utf-8")
          expect(fs.existsSync("package.json")).to.eql false
          expect(fs.existsSync(".vile.yml")).to.eql false
          process.chdir CWD
          process.nextTick -> done()

      it "can go through a default sequence", (done) ->
        answers = [
          [ /hello friend/i, [] ]
          [ /manually add paths/i, [ "y" ] ]
          [ /enter paths/i, [ "foo,bar" ] ]
          [ /frameworks and tooling/i, [] ]
          [ /look good/i, [ "y" ] ]
          [ /install required plugins/i, [ "n" ] ]
        ]

        proc = cli.exec_interactive "init",
          (question) ->
            match = _.find(answers, (answer) -> answer[0].test question)

            return if _.isEmpty match

            answers = _.reject(answers, (answer) -> answer == match)
            responses = match[1]
            #console.log "Q:", question
            #console.log "A:", responses.join(""), "ENTER"
            proc.stdin.write responses.join("") + press.ENTER
          ,
          (stdout) ->
            expect(fs.existsSync("package.json")).to.eql true
            expect(fs.existsSync(".vile.yml")).to.eql true
            expect(yml.safeLoad(fs.readFileSync(".vile.yml")))
              .to.eql {
                vile: {
                  allow: []
                  ignore: [ "node_modules", "foo", "bar" ]
                }
              }
            expect(stdout).to.match /created: .vile.yml/i
            expect(stdout).to
              .match /skipping: npm install \-\-save\-dev npm\-check\-updates/i
            expect(stdout).to
              .match /skipping: npm install \-\-save\-dev @forthright\/vile/i
            expect(stdout).to.match /vile-language/i
            expect(stdout).to.match /vile-stat/i
            expect(stdout).to.match /vile-ncu/i
            expect(stdout).to.match /looks like we are good to go/i
            expect(stdout).to.match /tips:/i
            expect(stdout).to.match /authenticate/i
            expect(stdout).to.match /upload/i
            expect(stdout).to.match /vile p/i
            expect(stdout).to.match /vile\.io/i
            expect(stdout).to
              .match /be sure to read up on your installed plugins/i
            process.nextTick -> done()

        return

    describe "with an empty, fresh project with specific languages", ->
      beforeEach ->
        process.chdir CLI_INIT_LANGS_DIR

      afterEach (done) ->
        rimraf CLI_INIT_LANGS_DIR + "/{.vile.yml,package.json,node_modules/*}",
          (err) ->
            throw err if err
            expect(fs.existsSync("package.json")).to.eql false
            expect(fs.existsSync(".vile.yml")).to.eql false
            process.chdir CWD
            process.nextTick -> done()

      it "has the expected directories ignore in .vile.yml", (done) ->
        answers = [
          [ /hello friend/i, [] ]
          [ /manually add paths/i, [ "n" ] ]
          [ /frameworks and tooling/i, [] ]
          [
            /It appears you speak our language/,
            [
              press.SPACE
              press.DOWN
              press.SPACE
              press.DOWN
              press.SPACE
            ]
          ]
          [ /Looks like you have tests/, [ "n" ] ]
          [ /look good/i, [ "y" ] ]
          [ /install required plugins and their peer dependencies/i, [ "n" ] ]
        ]

        cli_proc = cli.exec_interactive "init",
          (question) ->
            match = _.find(answers, (answer) -> answer[0].test question)

            return if _.isEmpty match

            answers = _.reject(answers, (answer) -> answer == match)
            responses = match[1]
            #console.log "Q:", question
            #console.log "A:", responses.join(""), "ENTER"
            cli_proc.stdin.write responses.join("") + press.ENTER
          ,
          (stdout) ->
            expect(fs.existsSync("package.json")).to.eql true
            expect(fs.existsSync(".vile.yml")).to.eql true
            expect(stdout).to.match /created: .vile.yml/i
            expect(stdout).to.match /vile-language/i
            expect(stdout).to.match /vile-stat/i
            expect(stdout).to.match /vile-eslint/i
            expect(stdout).to.match /vile-rubocop/i
            expect(stdout).to.match /vile-rubycritic/i
            expect(stdout).to.match /vile-tslint/i
            expect(stdout).to.match /vile-retire/i
            expect(stdout).to.match /vile-ncu/i
            expect(stdout).to
              .match /skipping: npm install \-\-save\-dev npm\-check\-updates/i
            expect(stdout).to
              .match /skipping: npm install \-\-save\-dev @forthright\/vile/i
            expect(stdout).to.match /looks like we are good to go/i
            process.nextTick -> done()

        return

    describe "with pre-existing ignorables and a .vile.yml", ->
      beforeEach ->
        process.chdir CLI_INIT_IGNORES_DIR

      afterEach (done) ->
        rimraf CLI_INIT_IGNORES_DIR +
          "/{.vile.yml,package.json,node_modules/*}",
          (err) ->
            throw err if err
            expect(fs.existsSync("package.json")).to.eql false
            expect(fs.existsSync(".vile.yml")).to.eql false
            fs.writeFileSync(
              path.join(CLI_INIT_IGNORES_DIR, ".vile.yml"), '\n', "utf-8")
            process.chdir CWD
            process.nextTick -> done()

      it "has the expected directories ignore in .vile.yml", (done) ->
        answers = [
          [ /hello friend/i, [] ]
          [ /found an existing \.vile\.yml/i, [ "y" ] ]
          [
            /Select any directories or files to ignore/i,
            [
              press.SPACE
              press.DOWN
              press.SPACE
              press.DOWN
              press.SPACE
              press.DOWN
              press.SPACE
              press.DOWN
              press.SPACE
            ]
          ]
          [ /manually add paths/i, [ "n" ] ]
          [ /frameworks and tooling/i, [] ]
          [ /Looks like you have tests/, [ "n" ] ]
          [ /look good/i, [ "y" ] ]
          [ /install required plugins and their peer dependencies/i, [ "n" ] ]
        ]

        cli_proc = cli.exec_interactive "init",
          (question) ->
            match = _.find(answers, (answer) -> answer[0].test question)

            return if _.isEmpty match

            answers = _.reject(answers, (answer) -> answer == match)
            responses = match[1]
            #console.log "Q:", question
            #console.log "A:", responses.join(""), "ENTER"
            cli_proc.stdin.write responses.join("") + press.ENTER
          ,
          (stdout) ->
            setTimeout ->
              expect(fs.existsSync("package.json")).to.eql true
              expect(fs.existsSync(".vile.yml")).to.eql true
              expect(yml.safeLoad(fs.readFileSync(".vile.yml")))
                .to.eql {
                  vile: {
                    allow: []
                    ignore: [
                      "node_modules"
                      ".build"
                      "coverage"
                      "tmp"
                      "vendor"
                    ]
                  }
                }
              expect(stdout).to.match /created: .vile.yml/i
              expect(stdout).to.match(
                /skipping: npm install \-\-save\-dev npm\-check\-updates/i)
              expect(stdout).to
                .match /skipping: npm install \-\-save\-dev @forthright\/vile/i
              expect(stdout).to.match /looks like we are good to go/i
              expect(stdout).to.match /tips:/i
              expect(stdout).to.match /authenticate/i
              expect(stdout).to.match /upload/i
              expect(stdout).to.match /vile p/i
              expect(stdout).to.match /vile\.io/i
              expect(stdout).to
                .match /be sure to read up on your installed plugins/i
              process.nextTick -> done()
            , 200

        return

  describe "punish", ->
    describe "combining files", ->
      beforeEach -> process.chdir CMB_FILES_DIR

      MAP = "-x src.ts:lib.js,diff_folder:diff_folder_rename"

      it "combines files", (done) ->
        cli.exec "p -n -d -f json #{MAP}", (stdout) ->
          expect(JSON.parse(stdout)).to
            .eql issues_combined
          done()

      it "does not combine files when not set", (done) ->
        cli.exec "p -n -d -f json", (stdout) ->
          expect(JSON.parse(stdout)).to
            .eql issues_not_combined
          done()

    describe "log level", ->
      beforeEach -> process.chdir SYNC_DIR

      it "can set the log level to error", (done) ->
        cli.exec "p -n -l error", (stdout) ->
          expect(stdout).not.to.match /test\-sync\-plugin\:start/i
          expect(stdout).not.to.match /test\-sync\-plugin\:finish/i
          done()

      it "can set the log level to warn", (done) ->
        cli.exec "p -n -l warn", (stdout) ->
          expect(stdout).not.to.match /test\-sync\-plugin\:start/i
          expect(stdout).not.to.match /test\-sync\-plugin\:finish/i
          done()

      it "can set the log level to info", (done) ->
        cli.exec "p -n -l info", (stdout) ->
          expect(stdout).to.match /test\-sync\-plugin\:start/i
          expect(stdout).to.match /test\-sync\-plugin\:finish/i
          done()

    describe "sync plugins", ->
      beforeEach -> process.chdir SYNC_DIR

      it "seems to run the plugin successfully", (done) ->
        cli.exec "p", (stdout) ->
          expect(stdout).to.match /test\-sync\-plugin\:start/i
          expect(stdout).to.match /test\-sync\-plugin\:finish/i
          done()

      it "returns a list of issues", (done) ->
        cli.exec "p -n -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify([
            { type: "ok", path:".vile.yml" }
            {
              type: "test",
              signature: "sync",
              plugin: "test-sync-plugin"
            }
          ])
          done()

      describe "without post processing", ->
        it "does not include any ok issues", (done) ->
          cli.exec "p -d -f json", (stdout) ->
            expect(stdout).to.eql JSON.stringify([
              {
                type: "test",
                signature: "sync",
                plugin: "test-sync-plugin"
              }
            ])
            done()

    describe "async plugins", ->
      beforeEach -> process.chdir ASYNC_DIR

      it "seems to run the plugin successfully", (done) ->
        cli.exec "p", (stdout) ->
          expect(stdout).to.match /test\-async\-plugin\:start/i
          expect(stdout).to.match /test\-async\-plugin\:finish/i
          done()

      it "returns a list of issues", (done) ->
        cli.exec "p -n -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify([
            { type: "ok", path:".vile.yml" }
            {
              type: "test",
              signature: "async",
              plugin: "test-async-plugin"
            }
          ])
          done()

      describe "without post processing", ->
        it "does not include any ok issues", (done) ->
          cli.exec "p -n -d -f json", (stdout) ->
            expect(stdout).to.eql JSON.stringify([
              {
                type: "test",
                signature: "async",
                plugin: "test-async-plugin"
              }
            ])
            done()

    describe "filtering and checking for installed plugins", ->
      beforeEach -> process.chdir PLUGIN_CHECK_DIR

      it "can run only one plugin", (done) ->
        cli.exec "p -p test-plugin-check-plugin-two -n -d -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify([
            {
              type: "test",
              signature: "two",
              plugin: "test-plugin-check-plugin-two"
            }
          ])
          done()

      it "will mention if a plugin is not installed", (done) ->
        cli.exec "p -p three", (stdout) ->
          expect(stdout).to.match /three is not installed/
          done()

    describe "code snippets", ->
      beforeEach -> process.chdir SNIPPET_DIR

      it "passes it as expected", (done) ->
        cli.exec "p -i -n -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify(issues_snippets)
          done()

    describe "filtering via ignore", ->
      beforeEach -> process.chdir FILTER_IGNORE_DIR

      it "returns a list of filtered issues", (done) ->
        cli.exec "p -n -d -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify([
            {
              type: "warning",
              path: "src/bar.js",
              plugin: "test-filtering-ignore-plugin"
            }
            {
              type: "warning",
              path: "src/foo.js",
              plugin: "test-filtering-ignore-plugin"
            }
            {
              type: "warning",
              path: "test.js",
              plugin: "test-filtering-ignore-plugin"
            }
          ])
          done()

    describe "filtering via allow", ->
      describe "via cli args", ->
        beforeEach -> process.chdir FILTER_ALLOW_DIR_VIA_CLI_ARGS

        it "returns a list of filtered issues", (done) ->
          cli.exec "p -n -d -f json src", (stdout) ->
            expect(stdout).to.eql JSON.stringify([
              {
                type: "error",
                path: "src/bar.js",
                plugin: "test-filtering-allow-via-cli-args-plugin"
              }
              {
                type: "error",
                path: "src/foo.js",
                plugin: "test-filtering-allow-via-cli-args-plugin"
              }
              {
                type: "error",
                path: "src/sub/bar.js",
                plugin: "test-filtering-allow-via-cli-args-plugin"
              }
            ])
            done()

      describe "via .vile.yml", ->
        beforeEach -> process.chdir FILTER_ALLOW_DIR

        it "returns a list of filtered issues", (done) ->
          cli.exec "p -n -d -f json", (stdout) ->
            expect(stdout).to.eql JSON.stringify([
              {
                type: "error",
                path: "src/bar.js",
                plugin: "test-filtering-allow-plugin"
              }
              {
                type: "error",
                path: "src/foo.js",
                plugin: "test-filtering-allow-plugin"
              }
              {
                type: "error",
                path: "src/sub/bar.js",
                plugin: "test-filtering-allow-plugin"
              }
            ])
            done()

    describe "spawning an external file/app that returns data", ->
      beforeEach -> process.chdir SPAWN_DIR

      it "returns a list of filtered issues", (done) ->
        cli.exec "p -n -d -f json", (stdout) ->
          expect(stdout).to.eql JSON.stringify([
            {
              type: "error",
              path: "filename.rb",
              plugin: "test-spawn-plugin"
            }
          ])
          done()
        return

    describe "spawning an external file/app that logs to stderr", ->
      beforeEach -> process.chdir SPAWN_STDERR_DIR

      it "logs the output to console", (done) ->
        cli.exec "p -n -d", (stdout) ->
          expect(stdout).to.match new RegExp("node warn OH NO!")
          expect(stdout).to.match new RegExp("test-spawn-stderr-plugin:start")
          expect(stdout).to.match new RegExp("test-spawn-stderr-plugin:finish")
          done()
        return

    describe "logging real issues", ->
      beforeEach -> process.chdir LOGGING_DIR

      it "logs the output to console as syntastic output", (done) ->
        cli.exec "p -n -d -f syntastic", (stdout) ->
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: warning msg", "gi"))
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: maintainability msg", "gi"))
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: undefined", "gi"))
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: undefined", "gi"))
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: error msg", "gi"))
          expect(stdout).to.match(
            new RegExp("a.ext:1:1: W: sec msg", "gi"))
          done()
        return

      it "logs the output to console", (done) ->
        cli.exec "p -n -d", (stdout) ->
          expect(stdout).to.match(
            new RegExp("plugin info test-logging-plugin:start", "gi"))
          expect(stdout).to.match(
            new RegExp("warning warn a.ext: line 1-2, warning msg", "gi"))
          expect(stdout).to.match(new RegExp(
            "maintainability warn a.ext: line 1-2, col 1, maintainability msg",
            "gi"
          ))
          expect(stdout).to.match(
            new RegExp("complexity info a.ext: 100", "gi"))
          expect(stdout).to.match new RegExp("churn info a.ext: 50", "gi")
          expect(stdout).to.match(
            new RegExp("duplicate warn a.ext: Similar code in a.ext", "gi"))
          expect(stdout).to.match(
            new RegExp(
              "dependency warn New release for dep: 0.0.1 < 0.1.0",
              "gi"
            ))
          expect(stdout).to.match(
            new RegExp("error error a.ext: error msg", "gi"))
          expect(stdout).to.match(
            new RegExp("security error a.ext: sec msg", "gi"))
          expect(stdout).to.match(
            new RegExp(
              "0\.097KB.*100 lines\, 80 loc\, 3 comments",
              "gi"
            ))
          expect(stdout).to.match new RegExp("lang info a.ext: ruby", "gi")
          expect(stdout).to.match new RegExp("git info sha: commit_date", "gi")
          expect(stdout).to.match(
            new RegExp("cov info a.ext: 90% lines covered", "gi"))
          expect(stdout).to.match new RegExp("ok info b.ext", "gi")
          expect(stdout).to.match(
            new RegExp("plugin info test-logging-plugin:finish", "gi"))
          done()
        return