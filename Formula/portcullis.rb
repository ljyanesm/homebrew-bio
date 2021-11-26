class Portcullis < Formula
  include Language::Python::Virtualenv
  # cite Mapleson_2017: "https://www.biorxiv.org/content/early/2017/11/10/217620"
  desc "Genuine splice junction prediction from BAM files"
  homepage "https://github.com/ei-corebioinformatics/portcullis"
  url "https://github.com/ei-corebioinformatics/portcullis/archive/refs/tags/Release-1.2.3.tar.gz"
  sha256 "172452b5cef12a8dcc2c1c68527000743114136ee63a0dbe307ac4e2a816bc99"
  license "GPL-3.0-only"
  head "https://github.com/ei-corebioinformatics/portcullis.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/brewsci/bio"
    sha256 sierra:       "52b593d877a74a1268a9bb75e40dc9fcd3ecc5e197d84dffec2fc01c0ec4bd79"
    sha256 x86_64_linux: "e91724794110a2c76755b1e480c479f1707d3dff25b6b7ef4b20f82e885fbf5c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  depends_on "boost"
  depends_on "gcc" # for gfortran
  depends_on "numpy"
  depends_on "python@3.9"
  depends_on "samtools"

  resource "tabulate" do
    url "https://files.pythonhosted.org/packages/ae/3d/9d7576d94007eaf3bb685acbaaec66ff4cdeb0b18f1bf1f17edbeebffb0a/tabulate-0.8.9.tar.gz"
    sha256 "eb1d13f25760052e8931f2ef80aaf6045a6cceb47514db8beab24cded16f13a7"
  end

  resource "pandas" do
    url "https://files.pythonhosted.org/packages/58/58/b729eda34f78060e14cb430c91d4f7ba3cf1e34797976877a3a1125ea5b2/pandas-1.3.4.tar.gz"
    sha256 "a2aa18d3f0b7d538e21932f637fbfe8518d085238b429e4790a35e1e44a96ffc"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz"
    sha256 "0123cacc1627ae19ddf3c27a5de5bd67ee4586fbdd6440d9748f8abb483d3e86"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/e3/8e/1cde9d002f48a940b9d9d38820aaf444b229450c0854bdf15305ce4a3d1a/pytz-2021.3.tar.gz"
    sha256 "acad2d8b20a1af07d4e4c9d2e9285c5ed9104354062f275f3fcd88dcef4f1326"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  def install
    ENV.prepend_path "PATH", libexec/"bin"
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    venv = virtualenv_create(libexec, "python3")
    resources.each do |r|
      venv.pip_install r
    end

    system "./autogen.sh"
    system "./configure",
      "--disable-silent-rules",
      "--disable-dependency-tracking",
      "--disable-py-install",
      "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    cd "scripts/portcullis" do
      system "python3", *Language::Python.setup_install_args(prefix)
    end
    cd "scripts/junctools" do
      system "python3", *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/portcullis --version")
  end
end
