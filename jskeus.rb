class Jskeus < Formula
  desc "EusLisp software used by JSK at The University of Tokyo"
  homepage "https://github.com/euslisp/jskeus"
  url "https://github.com/euslisp/jskeus/archive/1.0.13.tar.gz"
  sha256 "86437c939093d5c77776a6acf52453c49bdcb2b9d3b6e7956403ec34c476df7d"
  head "https://github.com/euslisp/jskeus.git"

  bottle do
    cellar :any
    sha256 "7565502a3d89709a9f78b64d1e1db135760bbcaa76cd9c884c006707c5fb7157" => :el_capitan
    sha256 "3bbb17d4248d11e341bd287bb60f6f920ca97a25923302fa020a2c197e7654eb" => :yosemite
    sha256 "0db86c355a4fdea0465d51314c6457c27cb535a8af9019601479edc929026197" => :mavericks
  end

  depends_on :x11
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "mesalib-glw"
  depends_on "wget" => :build

  resource "euslisp" do
    url "https://github.com/euslisp/EusLisp/archive/EusLisp-9.16.tar.gz"
    sha256 "1e60ba14d627ecb0f426bd60ea91df971855b2b076efa1c50598b420cab93a08"
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
      (bin/exec).write <<-EOS.undent
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
