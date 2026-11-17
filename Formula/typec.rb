# Copyright (c) 2026 Stanislav Sedov <stas@deglitch.com>
#
# SPDX-License-Identifier: BSD-2-Clause

class Typec < Formula
  desc "C11 with variants, generics and errors as values"
  homepage "https://github.com/stass/type-c"
  url "https://github.com/stass/type-c/archive/refs/tags/v0.2.tar.gz"
  sha256 "746e248a63604c3e3018bcfef887457ecde00609f716537ed41aa4c05b5fb13a"
  license "BSD-2-Clause"
  head "https://github.com/stass/type-c.git", branch: "master"

  depends_on "dune" => :build
  depends_on "ocaml" => :build

  def install
    system "dune", "build", "-p", "typec", "--profile", "release"
    system "dune", "install", "-p", "typec", "--prefix", prefix
  end

  test do
    (testpath/"shape.tc").write <<~EOS
      #include <stdio.h>

      type shape =
          | Circle(int r)
          | Rect(int w, int h);

      static int
      area(shape s)
      {
        match (s) {
        case Circle(r):
          return (3 * r * r);
        case Rect(w, h):
          return (w * h);
        }
      }

      int
      main(void)
      {
        printf("%d %d\\n", area(Circle(2)), area(Rect(3, 4)));
        return (0);
      }
    EOS
    system bin/"typec", "--cc=#{ENV.cc}", "shape.tc", "-o", "shape"
    assert_equal "12 12\n", shell_output("./shape")
  end
end
