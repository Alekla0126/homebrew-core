class Ratty < Formula
  desc "GPU-rendered terminal emulator with inline 3D graphics"
  homepage "https://ratty-term.org/"
  url "https://github.com/orhun/ratty/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "8d48b5c6adfc8543ed649a53221b61df129da415298c7875557c4fcb56255806"
  license "MIT"
  head "https://github.com/orhun/ratty.git", branch: "main"

  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "fontconfig"
    depends_on "wayland"
  end

  def install
    system "cargo", "install", *std_cargo_args
    pkgshare.install "config"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ratty --version")

    output_log = testpath/"output.log"
    if OS.mac?
      pid = spawn bin/"ratty", [:out, :err] => output_log.to_s
    else
      require "pty"
      r, _w, pid = PTY.spawn("#{bin}/ratty > #{output_log}")
      r.winsize = [80, 130]
    end
    sleep 1
    assert_match "Creating new window Ratty (0v0)", output_log.read
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
  end
end
