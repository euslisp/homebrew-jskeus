class Jskeus < Formula
  desc "EusLisp software used by JSK at The University of Tokyo"
  homepage "https://github.com/euslisp/jskeus"
  version "1.2.6"

  # Use pre-built binaries to avoid OpenGL build issues in Homebrew sandbox
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/euslisp/homebrew-jskeus/releases/download/1.2.6/jskeus-macos-arm64.tar.gz"
    sha256 "2fe9a14fc530525cf22279afb20d2f29c4ec7e56afe7930ae88ddd31555c6efd"
  elsif OS.mac? && Hardware::CPU.intel?
  end

  # Runtime dependencies only (no build dependencies needed for pre-built binaries)
  depends_on "wget" => :build
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "mesalib-glw"
  depends_on "libx11"
  on_macos do
    depends_on "mesa-glu"
  end

  def install
    on_macos do
      unless File.exist?("/opt/X11/bin/Xquartz")
        odie "XQuartz is required. Please install it first with: brew install --cask xquartz"
      end
    end

    # Install pre-built binary distribution
    prefix.install Dir["*"]

    arch_dir = "Darwin"
    executables = %w[eus eus0 eus1 eus2 euscomp eusg eusgl eusx irteus irteusgl]

    # Create wrapper scripts for executables with proper environment
    executables.each do |exec_name|
      actual_exec = nil
      if File.exist?(prefix/"eus"/arch_dir/"bin"/exec_name)
        actual_exec = prefix/"eus"/arch_dir/"bin"/exec_name
      elsif File.exist?(prefix/"irteus"/exec_name)
        actual_exec = prefix/"irteus"/exec_name
      end
      next unless actual_exec

      # Make executable
      chmod 0755, actual_exec

      (bin/exec_name).write <<~EOS
        #!/bin/bash
        export EUSDIR=#{opt_prefix}/eus
        export ARCHDIR=#{arch_dir}
        export PATH=$EUSDIR/$ARCHDIR/bin:$EUSDIR/$ARCHDIR/lib:$PATH
        export LD_LIBRARY_PATH=$EUSDIR/$ARCHDIR/lib:$EUSDIR/$ARCHDIR/bin:$LD_LIBRARY_PATH
        export DYLD_LIBRARY_PATH=$EUSDIR/$ARCHDIR/lib:$EUSDIR/$ARCHDIR/bin:$DYLD_LIBRARY_PATH
        exec "#{actual_exec}" "$@"
      EOS
      chmod 0755, bin/exec_name
    end
  end

  test do
    system "#{bin}/eus", "-e", "(exit)"
    system "#{bin}/irteusgl", "-e", "(exit)"
  end
end
