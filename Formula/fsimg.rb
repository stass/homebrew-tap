# Copyright (c) 2026 Stanislav Sedov <stas@deglitch.com>
#
# SPDX-License-Identifier: BSD-2-Clause

class Fsimg < Formula
  desc "Create, list, verify and extract filesystem images without mounting"
  homepage "https://github.com/stass/fsimg"
  url "https://github.com/stass/fsimg/releases/download/v0.1.0/fsimg-0.1.0.tar.xz"
  sha256 "4a07f508d0ba174e5219b6ab811a962c6f084d1edc1a62a1bd243c1e1e95f003"
  license "BSD-2-Clause"

  depends_on "pkgconf" => [:build, :test]
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "zlib"

  def install
    system "./configure", "--disable-silent-rules", "--with-zstd=yes",
           "--with-xz=yes", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"tree/sub").mkpath
    (testpath/"tree/sub/hello.txt").write "hello\n"
    system bin/"fsimg", "c", "-f", "disk.img", "-F", "fat32", "-M",
           "-C", "tree", "."
    assert_match "/sub/hello.txt", shell_output("#{bin}/fsimg t -f disk.img")
    assert_equal "hello\n",
                 shell_output("#{bin}/fsimg x -O -f disk.img sub/hello.txt")
    system bin/"fsimg", "W", "-f", "disk.img"

    # The library, compiled as an embedder compiles against it.
    (testpath/"ctx.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>

      #include <fsimg.h>

      int
      main(void)
      {
        fsimg_options_t options;
        fsimg_ctx_t *ctx = NULL;
        fsimg_error_t error;
        fsimg_status_t status;

        fsimg_options_init(&options);
        status = fsimg_ctx_new(&options, &ctx, &error);
        printf("%s\\n", fsimg_status_string(status));
        fsimg_ctx_free(ctx);

        return (status == FSIMG_OK ? EXIT_SUCCESS : EXIT_FAILURE);
      }
    EOS
    flags = shell_output("pkgconf --cflags --libs libfsimg").split
    system ENV.cc, "ctx.c", "-o", "ctx", *flags
    system "./ctx"
  end
end
