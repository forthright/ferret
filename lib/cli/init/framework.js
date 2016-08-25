"use strict";

/// <reference path="../../lib/typings/index.d.ts" />
var fs = require("fs");
var path = require("path");
var Bluebird = require("bluebird");
var inquirer = require("inquirer");
var _ = require("lodash");
var plugin_map = require("./map");
var exists = function exists(file) {
    return fs.existsSync(path.join(process.cwd(), file));
};
var read = function read(file) {
    return fs.readFileSync(file).toString();
};
var check_for_project_frameworks = function check_for_project_frameworks(config) {
    var frameworks = [];
    if (exists("config.ru") && /Rails/.test(read("config.ru"))) {
        frameworks.push("rails");
    }
    // TODO: a lot of false positives here (atom, etc)
    if (exists("node_modules") || exists("package.json")) {
        frameworks.push("nodejs");
    }
    if (exists("bower.json")) frameworks.push("bower");
    if (exists("Gemfile")) frameworks.push("bundler");
    if (exists(".editorconfig")) frameworks.push("editorconfig");
    if (exists(".retireignore")) frameworks.push("retirejs");
    if (exists(".eslintrc") || exists(".eslintrc.yml") || exists(".eslintrc.yaml") || exists(".eslintrc.json") || exists(".eslintrc.js")) {
        frameworks.push("eslint");
    }
    if (exists(".jshintrc") || exists(".jshintignore")) {
        frameworks.push("jshint");
    }
    if (exists("coffeelint.json")) frameworks.push("coffeelint");
    if (exists(".sass-lint.yml")) frameworks.push("sass-lint");
    if (exists(".rubocop.yml")) frameworks.push("rubocop");
    if (exists(".slim-lint.yml")) frameworks.push("slim-lint");
    if (exists(".brakeman.yml")) frameworks.push("brakeman");
    if (exists(".git")) frameworks.push("git");
    return inquirer.prompt({
        type: "checkbox",
        message: "Looks like you have a number of frameworks and tooling." + " Please uncheck any that don't apply?",
        name: "frameworks",
        choices: _.map(frameworks, function (name) {
            return { name: name, checked: true };
        }),
        validate: function validate(answer) {
            return true;
        }
    }).then(function (answers) {
        _.each(_.get(answers, "frameworks", []), function (name) {
            _.each(plugin_map.frameworks[name], function (plugin) {
                config.vile.plugins.push(plugin);
            });
        });
        if (_.isEmpty(frameworks)) return Bluebird.resolve(config);
        // strain out any dupes
        config.vile.plugins = _.uniq(config.vile.plugins);
        return config;
    });
};
module.exports = {
    init: check_for_project_frameworks
};