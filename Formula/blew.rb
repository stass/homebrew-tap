class Blew < Formula
  desc "BLE scanner and CLI tool for macOS"
  version "0.3.0"
  homepage "https://github.com/stass/blew"
  url "https://github.com/stass/blew/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "7c15c86f360a80b0030417746c5eeaedf975e8a2a8e250f1df8aa24ab764e953"
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
