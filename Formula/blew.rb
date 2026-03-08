class Blew < Formula
  desc "BLE scanner and CLI tool for macOS"
  version "0.2.1"
  homepage "https://github.com/stass/blew"
  url "https://github.com/stass/blew/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "0d78097de89cdc60811621904ccd568740a308ebe2dfe3726a4e09d7654dc0a8"
  license "BSD-2-Clause"

  depends_on :macos
  depends_on xcode: ["15.0", :build]

  resource "bluetooth-numbers-database" do
    url "https://github.com/NordicSemiconductor/bluetooth-numbers-database/archive/85317212ef563adcc57e575793a24e679c81b724.tar.gz"
    sha256 "263b194aa90cf6ea95428b50876375785f62818d754462ef187a7ec6d40360f2"
  end

  resource "bluetooth-SIG" do
    url "https://bitbucket.org/bluetooth-SIG/public/get/8e18798ea17a4471e093a543b48e33e72d9f211d.tar.gz"
    sha256 "e10a707a435da83c13c655f0134d14672c6e71b01ac61668affffcde938492de"
  end

  def install
    resource("bluetooth-numbers-database").stage do
      (buildpath/"Vendor/bluetooth-numbers-database").install Dir["*"]
    end
    resource("bluetooth-SIG").stage do
      (buildpath/"Vendor/bluetooth-SIG").install Dir["*"]
    end

    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/blew"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/blew --version")
  end
end
