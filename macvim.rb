require 'formula'

class Macvim < Formula
  desc 'GUI for vim, made for OS X'
  #homepage 'https://github.com/macvim-dev/macvim'
  #head 'https://github.com/macvim-dev/macvim.git'
  homepage 'https://github.com/hermanzhu/macvim'
  head 'https://github.com/hermanzhu/macvim.git'

  option 'with-properly-linked-python2-python3', 'Link with properly linked Python 2 and Python 3. You will get deadly signal SEGV if you don\'t have properly linked Python 2 and Python 3.'

  depends_on 'gettext' => :build
  depends_on 'lua' => :build
  depends_on :python3 => :build

  def install
    perl_version = '5.16'
    ENV.append 'VERSIONER_PERL_VERSION', perl_version
    ENV.append 'VERSIONER_PYTHON_VERSION', '2.7'
    ENV.append 'vi_cv_path_python3', "#{HOMEBREW_PREFIX}/bin/python3"
    ENV.append 'vi_cv_path_plain_lua', "#{HOMEBREW_PREFIX}/bin/lua"
    ENV.append 'vi_cv_dll_name_perl', "/System/Library/Perl/#{perl_version}/darwin-thread-multi-2level/CORE/libperl.dylib"
    ENV.append 'vi_cv_dll_name_python3', "#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/3.5/Python"

    opts = []
    if build.with? 'properly-linked-python2-python3'
      opts << '--with-properly-linked-python2-python3'
    end

    system './configure', "--prefix=#{prefix}",
                          '--with-features=huge',
                          '--enable-multibyte',
                          '--enable-netbeans',
                          '--with-tlib=ncurses',
                          '--enable-cscope',
                          '--enable-termtruecolor',
                          '--enable-perlinterp=dynamic',
                          '--enable-pythoninterp=dynamic',
                          '--enable-python3interp=dynamic',
                          '--enable-rubyinterp=dynamic',
                          '--with-ruby-command=/usr/bin/ruby',
                          '--enable-luainterp=dynamic',
                          "--with-lua-prefix=#{HOMEBREW_PREFIX}",
                          *opts

    system 'make'

    prefix.install 'src/MacVim/build/Release/MacVim.app'
    bin = prefix + 'bin'

    bin.install 'src/MacVim/mvim'
    mvim = bin + 'mvim'
    [
      'vim', 'vimdiff', 'view',
      'gvim', 'gvimdiff', 'gview',
      'mvimdiff', 'mview'
    ].each do |t|
      ln_s 'mvim', bin + t
    end
    inreplace mvim do |s|
      s.gsub! /^# (VIM_APP_DIR=).*/, "\\1\"#{prefix}\""
    end
  end

  test do
    (testpath/'a').write 'hai'
    (testpath/'b').write 'bai'
    system bin/'vimdiff', 'a', 'b',
           '-c', 'FormatCommand diffformat',
           '-c', 'w! diff.html', '-c', 'qa!'
    File.exist? 'diff.html'
  end
end
