class Ferret < Formula
  desc "Open platform for continuous software analysis"
  homepage "https://github.com/forthright/ferret_temp"
  url "https://github.com/forthright/ferret_temp/releases/download/#FERRET_VERSION#/ferret-#FERRET_VERSION#-mac-x86_64.tar.gz"
  sha256 "#FERRET_SHA#"

  def install
    bin.install "bin/ferret"
    prefix.install "default"
    prefix.install "node_modules"
    # HACK: this definitely isn't the right way to avoid homebrew auto
    #       assuming lib gets symlinked. Still, we don't want
    #       to pollute /usr/local/lib node, but instead have a /opt like install
    mv "lib", "_lib"
    prefix.install "_lib"
  end

  def post_install
    mv prefix/"_lib", prefix/"lib"
  end
end
