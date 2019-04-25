class Jskeus < Formula
  desc "EusLisp software used by JSK at The University of Tokyo"
  homepage "https://github.com/euslisp/jskeus"
  url "https://github.com/euslisp/jskeus/archive/1.2.1.tar.gz"
  sha256 "69788a9b8d4b2137c84df475b9ea02e708a036246d3a3d4c7e16a390ce35b7ae"
  head "https://github.com/euslisp/jskeus.git"

  depends_on :x11
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "mesalib-glw"
  depends_on "wget" => :build

  resource "euslisp" do
    url "https://github.com/euslisp/EusLisp/archive/EusLisp-9.23.tar.gz"
    sha256 "6c4436ddbdfd8bf065717a98cfd9d262ce283b06fff5b223b48dd2cf5fe3998f"
  end

  def install
    ENV.deparallelize
    ENV.O0

    # jskeus needs to be compiled in Cellar
    prefix.install "Makefile", Dir["{doc,images,irteus}"]
    (prefix/"eus").install resource("euslisp")

    executables = ["eus", "eus0", "eus1", "eus2", "euscomp", "eusg", "eusgl", "eusx", "irteus", "irteusgl"]

    cd prefix do
      system "make"

      executables.each do |exec|
        libexec.install "eus/Darwin/bin/#{exec}"
      end
    end

    bin.mkpath
    executables.each do |exec|
      (bin/exec).write <<~EOS
        #!/bin/bash
        EUSDIR=#{opt_prefix}/eus ARCHDIR=Darwin LD_LIBRARY_PATH=$EUSDIR/$ARCHDIR/bin:$LD_LIBRARY_PATH exec #{libexec}/#{exec} "$@"
      EOS
    end
  end

  test do
    system "#{bin}/eus", "(exit)"
    system "#{bin}/irteusgl", "(exit)"
  end
end
