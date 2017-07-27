class Gifme < Formula
  desc "Wrapper for ffmpeg to ease the creation of high-quality gifs from videos"
  homepage "https://github.com/scottpham/gifme"
  url "https://github.com/scottpham/gifme.git",
    :revision => "456756e9ca7f8a359417a8a91bbfacb7a4b0924b"
  version "1"
  head "https://github.com/scottpham/gifme.git"

  bottle :unneeded

  depends_on "ffmpeg"

  def install
    bin.install "gifme.sh" => "gifme"
  end

  test do
    system "#{bin}/gifme"
  end
end
