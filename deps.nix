{ pkgs, ... }:
with pkgs; let

  json-minify = (buildRubyGem {
    gemName = "json-minify";
    dependencies = [ rubyPackages.json ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "fd38ef93867332c2340aaf1b57335782ab5958fe6fb3ca7a8aba1469f0bf08ae";
      type = "gem";
    };
    version = "0.0.3";
  });

  htmlcompressor = (buildRubyGem {
    gemName = "htmlcompressor";
    dependencies = [ ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "4630cf8ed46b563f0b49cc6028a3fe8c17a9067f2becd7c3a2aa5aaacefb1f9e";
      type = "gem";
    };
    version = "0.4.0";
  });

  cssminify2 = (buildRubyGem {
    gemName = "cssminify2";
    dependencies = [ ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "e311cfced4ccfc55d27bf30520f7d11ed129bf04dcadd5a82e791a141e45b98c";
      type = "gem";
    };
    version = "2.0.1";
  });

  jekyll-katex = (buildRubyGem {
    gemName = "jekyll-katex";
    dependencies = [ rubyPackages.execjs jekyll ];
    nativeBuildInputs = [ rubyPackages.execjs jekyll ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "ff16aced6a4577a76bf429c853a055ff6511a06f8fee06028adc26aaf28f58cd";
      type = "gem";
    };
    version = "1.0.0";
  });
 
  jekyll-minifier = (buildRubyGem {
    gemName = "jekyll-minifier";
    dependencies = [ cssminify2 htmlcompressor rubyPackages.jekyll json-minify rubyPackages.uglifier ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "cd05bd9b2105f1dfd344397c480c17bea7d93871e239f5ca3949852ff1d938a3";
      type = "gem";
    };
    version = "0.1.10";
  });

  jekyll-agda = (buildRubyGem {
    gemName = "jekyll-agda";
    dependencies = [ agda jekyll ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "fb2af6ac3ce9f11260b1c3d8e28075f23436577e5172e7defa029fb90e808fa3";
      type = "gem";
    };
    version = "0.1.0";
  });

  katex = (buildRubyGem {
    gemName = "katex";
    dependencies = [ rubyPackages.execjs ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "f17360dd98b7b42288cb35dfa7d405ce9ec7e290c9d8a06d7f0fc8774fbfa6eb";
      type = "gem";
    };
    version = "0.10.0";
  });

  kramdown-math-katex = (buildRubyGem {
    gemName = "kramdown-math-katex";
    dependencies = [ katex rubyPackages.kramdown ];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "7119b299fed5ec49b9e2107d18e88f90acf4bbdf1b82a7568fd488790bb04cdc";
      type = "gem";
    };
    version = "1.0.1";
  });

  rubyEnv = ruby.withPackages (ps: with ps; [
      jekyll
      jekyll-feed
      jekyll-katex
      jekyll-minifier
      jekyll-agda
      kramdown-parser-gfm
      kramdown-math-katex
      katex
      execjs
      uglifier
      htmlcompressor
      cssminify2
      json-minify
      webrick
      rouge
    ]);
in
[ nodejs inkscape scour ] ++ rubyEnv.gems
