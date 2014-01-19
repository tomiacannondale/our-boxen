class people::tomiacannondale {
  include dropbox
  include chrome
  include firefox
  include mactex::full
  include vlc
  include imagemagick
  include zsh

  include osx::dock::autohide

  # install ricty
  homebrew::tap { 'sanemat/font': }
  package { 'sanemat/font/ricty':
    require => Homebrew::Tap["sanemat/font"]
  }
  exec { 'set ricty':
    command => "cp -f ${homebrew::config::installdir}/share/fonts/Ricty*.ttf ~/Library/Fonts/ && fc-cache -vf",
    require => Package["sanemat/font/ricty"]
  }

  package { 'emacs':
    install_options => [
      '--japanese',
      '--cocoa'
    ]
  }

  package {
    [
     'tree',
     'graphviz',
     'cvs',
     'w3m',
     'libxml2',         # for nokogiri
     'libxslt',         # for nokogiri
     'gpg'
     ]:
  }

  package {
    'GoogleJapaneseInput':
      source   =>   "http://dl.google.com/japanese-ime/latest/GoogleJapaneseInput.dmg",
      provider =>   "pkgdmg"
  }

  $home     = "/Users/${::boxen_user}"
  $dotemacs = "${home}/.emacs.d"
  $elisp    = "${dotemacs}/elisp"

  $snippets = "${dotemacs}/etc/snippets"
  $rubysnippets = "${snippets}/ruby-mode"
  $rspecsnippets = "${snippets}/rspec-mode"

  $dotzsh   = "${home}/.zsh.d"
  $zshplugins  = "${dotzsh}/plugins"
  $ohmyzsh  = "${zshplugins}/oh-my-zsh"
  $autofu   = "${zshplugins}/auto-fu.zsh"

  $dotfiles = "${home}/dot_files"

  # emacs
  repository { $dotemacs:
    source => "tomiacannondale/dot.emacs.d"
  }

  file { "${dotemacs}/etc":
    ensure => directory,
    require => Repository[$dotemacs]
  }

  file { $snippets:
    ensure => directory,
    require => File["${dotemacs}/etc"]
  }

  repository { $rubysnippets:
    source => "tomiacannondale/ruby-mode-yasnippets",
    require => File[$snippets]
  }

  repository { $rspecsnippets:
    source => "tomiacannondale/rspec-yasnippets",
    require => File[$snippets]
  }

  file { $elisp:
    ensure => directory,
    require => Repository[$dotemacs]
  }

  repository { "${elisp}/exec-path-from-shell":
    source => "purcell/exec-path-from-shell",
    require => File[$elisp]
  }

  file { "${dotemacs}/conf/local":
    ensure => directory,
    require => Repository[$dotemacs]
  }

  # zsh
  repository { $dotzsh:
    source => "tomiacannondale/dot.zsh.d"
  }

  file { "${home}/.zshrc":
    ensure => link,
    target => "${dotzsh}/zshrc",
    require => Repository[$dotzsh]
  }

  file { "${home}/.zshenv":
    ensure => link,
    target => "${dotzsh}/zshenv",
    require => Repository[$dotzsh]
  }

  file { $zshplugins:
    ensure => directory,
    require => Repository[$dotzsh]
  }

  repository { $ohmyzsh:
    source => "robbyrussell/oh-my-zsh",
    require => File[$zshplugins]
  }

  class { 'ruby::global':
    version => '2.0.0'
  }

  class { 'nodejs::global':
    version => 'v0.10'
  }
}
