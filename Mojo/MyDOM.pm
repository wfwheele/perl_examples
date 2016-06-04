package Mojo::MyDOM;
use Mojo::Base -base;
use overload 'bool' => sub {1}, fallback => 1;
use overload '""' => sub { shift->to_xml }, fallback => 1;

use Mojo::Util qw/decode encode html_unescape xml_escape/;
use Scalar::Util 'weaken';

use Mojo::JSON;

# "How are the kids supposed to get home?
#  I dunno. Internet?"
has 'charset';
has tree => sub { ['root'] };

# Regex
my $CSS_ESCAPE_RE = qr/\\[^0-9a-fA-F]|\\[0-9a-fA-F]{1,6}/;
my $CSS_ATTR_RE   = qr/
  \[
  ((?:$CSS_ESCAPE_RE|\w)+)      # Key
  (?:
  (\W)?                         # Operator
  =
  (?:"((?:\\"|[^"])+)"|(\S+))   # Value
  )?
  \]
/x;
my $CSS_CLASS_RE        = qr/\.((?:\\\.|[^\.])+)/;
my $CSS_ELEMENT_RE      = qr/^((?:\\\.|\\\#|[^\.\#])+)/;
my $CSS_ID_RE           = qr/\#((?:\\\#|[^\#])+)/;
my $CSS_PSEUDO_CLASS_RE = qr/(?:\:([\w\-]+)(?:\(((?:\([^\)]+\)|[^\)])+)\))?)/;
my $CSS_TOKEN_RE        = qr/
  (\s*,\s*)?                                        # Separator
  ((?:[^\[\\\:\s\,]|$CSS_ESCAPE_RE\s?)+)?           # Element
  ((?:\:[\w\-]+(?:\((?:\([^\)]+\)|[^\)])+\))?)*)?   # Pseudoclass
  ((?:\[
    (?:$CSS_ESCAPE_RE|\w)+                          # Key
    (?:\W?=                                         # Operator
      (?:"(?:\\"|[^"])+"|\S+)                       # Value
    )?
  \])*)?
  (?:
  \s*
  ([\>\+\~])                                        # Combinator
  )?
/x;
my $XML_ATTR_RE = qr/
  \s*
  ([^=\s>"']+)     # Key
  (?:
    \s*
    =
    \s*
    (?:
      "([^"]*?)"   # Quotation marks
      |
      '([^']*?)'   # Apostrophes
      |
      ([^>\s]+)    # Unquoted
    )
  )?
  \s*
/x;
my $XML_END_RE   = qr/^\s*\/\s*(.+)\s*/;
my $XML_START_RE = qr/([^\s\/]+)([\s\S]*)/;
my $XML_TOKEN_RE = qr/
  ([^<]*)                    # Text
  (?:
    <\?(.*?)\?>              # Processing Instruction
    |
    <\!--(.*?)-->            # Comment
    |
    <\!\[CDATA\[(.*?)\]\]>   # CDATA
    |
    <\!DOCTYPE([^>]*)>       # DOCTYPE
    |
    <(
      \s*
      [^>\s]+                # Tag
      (?:$XML_ATTR_RE)*      # Attributes
    )>
  )??
/xis;

# Optional HTML tags
my @OPTIONAL_TAGS =
  qw/body colgroup dd head li optgroup option p rt rp tbody td tfoot th/;
my $HTML_AUTOCLOSE_RE = join '|', @OPTIONAL_TAGS;
$HTML_AUTOCLOSE_RE = qr/^(?:$HTML_AUTOCLOSE_RE)$/;

# Tags that break HTML paragraphs
my @PARAGRAPH_TAGS = (
  qw/address article aside blockquote dir div dl fieldset footer form h1 h2/,
  qw/h3 h4 h5 h6 header hgroup hr menu nav ol p pre section table or ul/
);
my $HTML_PARAGRAPH_RE = join '|', @PARAGRAPH_TAGS;
$HTML_PARAGRAPH_RE = qr/^(?:$HTML_PARAGRAPH_RE)$/;

sub add_after  { shift->_add(1, @_) }
sub add_before { shift->_add(0, @_) }

sub all_text {
  my $self = shift;

  # Text
  my $text = '';

  # Tree
  my $tree = $self->tree;

  # Walk tree
  my $start = $tree->[0] eq 'root' ? 1 : 4;
  my @stack = @$tree[$start .. $#$tree];
  while (my $e = shift @stack) {

    # Type
    my $type = $e->[0];

    unshift @stack, @$e[4 .. $#$e] and next if $type eq 'tag';

    # Text or CDATA
    if ($type eq 'text' || $type eq 'cdata' || $type eq 'raw') {
      my $content = $e->[1];
      $text .= $content if $content =~ /\S+/;
    }
  }

  return $text;
}

sub at { shift->find(@_)->[0] }

sub attrs {
  my $self = shift;

  # Tree
  my $tree = $self->tree;

  # Root
  return if $tree->[0] eq 'root';

  # Attributes
  my $attrs = $tree->[2];

  # Hash
  return $attrs unless @_;

  # Get
  return $attrs->{$_[0]} unless @_ > 1 || ref $_[0];

  # Set
  my $values = ref $_[0] ? $_[0] : {@_};
  for my $key (keys %$values) {
    $attrs->{$key} = $values->{$key};
  }

  return $self;
}

sub children {
  my $self = shift;

  # Children
  my @children;

  # Tree
  my $tree = $self->tree;

  # Walk tree
  my $start = $tree->[0] eq 'root' ? 1 : 4;
  for my $e (@$tree[$start .. $#$tree]) {

    # Tag
    next unless $e->[0] eq 'tag';

    # Add child
    push @children, $self->new(charset => $self->charset, tree => $e);
  }

  return \@children;
}

sub find {
  my ($self, $css) = @_;

  # Parse CSS selectors
  my $pattern = $self->_parse_css($css);

  # Filter tree
  return $self->_match_tree($self->tree, $pattern);
}

sub inner_xml {
  my $self = shift;

  # Tree
  my $tree = $self->tree;

  # Walk tree
  my $result = '';
  my $start = $tree->[0] eq 'root' ? 1 : 4;
  for my $e (@$tree[$start .. $#$tree]) {

    # Render
    $result .= $self->_render($e);
  }

  # Encode
  my $charset = $self->charset;
  encode $charset, $result if $charset;

  return $result;
}

sub namespace {
  my $self = shift;

  # Current
  my $current = $self->tree;
  return if $current->[0] eq 'root';

  # Prefix
  my $prefix = '';
  if ($current->[1] =~ /^(.*?)\:/) { $prefix = $1 }

  # Walk tree
  while ($current) {

    # Root
    return if $current->[0] eq 'root';

    # Attributes
    my $attrs = $current->[2];

    # Namespace for prefix
    if ($prefix) {
      for my $key (keys %$attrs) {
        return $attrs->{$key} if $key =~ /^xmlns\:$prefix$/;
      }
    }

    # Namespace attribute
    if (my $namespace = $attrs->{xmlns}) { return $namespace }

    # Parent
    $current = $current->[3];
  }
}

sub parent {
  my $self = shift;

  # Tree
  my $tree = $self->tree;

  # Root
  return if $tree->[0] eq 'root';

  # Parent
  return $self->new(charset => $self->charset, tree => $tree->[3]);
}

sub parse {
  my ($self, $xml) = @_;

  # Detect Perl characters
  $self->charset(undef) if utf8::is_utf8 $xml;

  # Parse
  $self->tree($self->_parse_xml($xml));
}

sub replace {
  my ($self, $new) = @_;

  # Parse
  $new = $self->_parse_xml("$new");

  # Tree
  my $tree = $self->tree;

  # Root
  return $self->replace_inner(
    $self->new(charset => $self->charset, tree => $new))
    if $tree->[0] eq 'root';

  # Parent
  my $parent = $tree->[3];

  # Replacements
  my @new;
  for my $e (@$new[1 .. $#$new]) {
    $e->[3] = $parent if $e->[0] eq 'tag';
    push @new, $e;
  }

  # Find
  my $i = $parent->[0] eq 'root' ? 1 : 4;
  for my $e (@$parent[$i .. $#$parent]) {
    last if $e == $tree;
    $i++;
  }

  # Replace
  splice @$parent, $i, 1, @new;

  return $self;
}

sub replace_inner {
  my ($self, $new) = @_;

  # Parse
  $new = $self->_parse_xml("$new");

  # Tree
  my $tree = $self->tree;

  # Replacements
  my @new;
  for my $e (@$new[1 .. $#$new]) {
    $e->[3] = $tree if $e->[0] eq 'tag';
    push @new, $e;
  }

  # Replace
  my $start = $tree->[0] eq 'root' ? 1 : 4;
  splice @$tree, $start, $#$tree, @new;

  return $self;
}

sub root {
  my $self = shift;

  # Find root
  my $root = $self->tree;
  while ($root->[0] eq 'tag') {
    last unless my $parent = $root->[3];
    $root = $parent;
  }

  return $self->new(charset => $self->charset, tree => $root);
}

sub text {
  my $self = shift;

  # Text
  my $text = '';

  # Walk stack
  for my $e (@{$self->tree}) {

    # Meta data
    next unless ref $e eq 'ARRAY';

    # Type
    my $type = $e->[0];

    # Text or CDATA
    if ($type eq 'text' || $type eq 'cdata' || $type eq 'raw') {
      my $content = $e->[1];
      $text .= $content if $content =~ /\S+/;
    }
  }

  return $text;
}

sub to_xml {
  my $self = shift;

  # Render
  my $result = $self->_render($self->tree);

  # Encode
  my $charset = $self->charset;
  encode $charset, $result if $charset;

  return $result;
}

sub to_json {
  my $self = shift;

  my $json = new Mojo::JSON;

  # Render
  my $result = $self->_render_json($self->tree, $json, 0);

  # Encode
  #my $charset = $self->charset;
  #encode $charset, $result if $charset;

  return $result;
}

sub _render_json {
  my ($self, $tree, $json, $level) = @_;

  # Element
  my $e = $tree->[0];

  # Text
  return $tree->[1]
    if ($e eq 'text' || $e eq 'raw' || $e eq 'doctype'
        || $e eq 'comment' || $e eq 'cdata' || $e eq 'pi');

  # Offset
  my $start = $e eq 'root' ? 1 : 2;

  # Content
  my $content = '';

  $content .= '{'
    if $e eq 'root';

  # Start tag
  my $attrs;
  if ($e eq 'tag') {

    # Offset
    $start = 4;

    # special case
    $content .= '{ "'.$tree->[1].'": [ '
      if ($level == 0);

    # Open tag
    $content .= '{ ';

    # Attributes
    my @attrs;
    for my $key (sort keys %{$tree->[2]}) {
      my $value = $tree->[2]->{$key};

      # No value
      push @attrs, '"'.$key.'": true ' and next unless $value;

      # Escape
      $value = $json->encode ( $value );

      # Key and value
      push @attrs, qq/"$key": $value/;
    }
    $attrs = join ', ', @attrs;
    $content .= ' "_attributes": { '.$attrs.'} ' if $attrs;

    # Empty tag
    return "$content }" unless $tree->[4];
  }

  # Walk tree
  my $groups = {
        'tags' => {},
        'text' => '',
        'doctype' => '',
        'pis' => [],
        'comments' => [],
        'cdata' => []
        };
  my $tag;
  for my $i ($start .. $#$tree) {

    # group tags, comments, text (not empty), pi an doctype

    if ($tree->[$i]->[0] eq 'tag')
      {
        $tag = $tree->[$i]->[1];
        $groups->{'tags'}->{ $tag } = []
          unless (exists $groups->{'tags'}->{ $tag });

        push @{ $groups->{'tags'}->{ $tag } },
                $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[0] eq 'text' && $tree->[$i]->[1] !~ m/^[\n\t\r\s]*$/m)
      {
        $groups->{'text'} .= $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[0] eq 'doctype' && $tree->[$i]->[1] !~ m/^[\n\t\r\s]*$/m)
      {
        $groups->{'doctype'} .= $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[0] eq 'pi')
      {
        push @{$groups->{'pis'}}, $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[0] eq 'comment')
      {
        push @{$groups->{'comments'}}, $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[0] eq 'cdata')
      {
        push @{$groups->{'cdata'}}, $self->_render_json($tree->[$i], $json, $level+1);
      }
    elsif ($tree->[$i]->[1] !~ m/^[\n\t\r\s]*$/m)
      {
        $groups->{'text'} .= $self->_render_json($tree->[$i], $json, $level+1);
      }
  }

  if (scalar( keys %{ $groups->{'tags'} } ) > 0)
    {
      $content .= ", "
        if ($attrs);

      $content .= join(", ", map {
        $tag = $_;
        ' "'.$tag.'" : [ '.join (", ", @{ $groups->{'tags'}->{$tag} }). " ]";

        } sort keys %{ $groups->{'tags'} });
    }

  if ($groups->{'text'} ne '')
    {
      $content .= ", "
        if($attrs || scalar(keys %{ $groups->{'tags'} }) > 0);

      $content .= '"_text": '. $json->encode ($groups->{'text'});
    }

  if ($groups->{'doctype'} ne '')
    {
      $content .= ", "
        if($attrs || scalar(keys %{ $groups->{'tags'} }) > 0 || $groups->{'text'} ne '');

      $content .= '"_doctype": '. $json->encode ($groups->{'doctype'});
    }

  if (scalar(@{$groups->{'pis'}}) > 0)
    {
      $content .= ", "
        if($attrs || scalar(keys %{ $groups->{'tags'} }) > 0 || $groups->{'text'} ne ''
           || $groups->{'doctype'} ne '');

      $content .= '"_pis": [ '. join(", ", map { $json->encode ($_) } @{$groups->{'pis'}} ) . ' ]';
    }

  if (scalar(@{$groups->{'comments'}}) > 0)
    {
      $content .= ", "
        if($attrs || scalar(keys %{ $groups->{'tags'} }) > 0 || $groups->{'text'} ne ''
           || $groups->{'doctype'} ne '' || scalar(@{$groups->{'pis'}}) > 0);

      $content .= '"_comments": [ '. join(", ", map { $json->encode ($_) } @{$groups->{'comments'}} ) . ' ]';
    }

  if (scalar(@{$groups->{'cdata'}}) > 0)
    {
      $content .= ", "
        if($attrs || scalar(keys %{ $groups->{'tags'} }) > 0 || $groups->{'text'} ne ''
           || $groups->{'doctype'} ne '' || scalar(@{$groups->{'pis'}}) > 0 || scalar(@{$groups->{'comments'}}) > 0);

      $content .= '"_cdata": [ '. join(", ", map { $json->encode ($_) } @{$groups->{'cdata'}} ) . ' ]';
    }

  # End tag
  $content .= ' }'
    if ($e eq 'tag');

  $content .= '] }'
    if ($level == 0 && $e ne 'root');

  $content .= '}'
    if $e eq 'root';

  return $content;
}  

sub type {
  my ($self, $type) = @_;

  # Tree
  my $tree = $self->tree;

  # Root
  return if $tree->[0] eq 'root';

  # Get
  return $tree->[1] unless $type;

  # Set
  $tree->[1] = $type;

  return $self;
}

sub _add {
  my ($self, $offset, $new) = @_;

  # Parse
  $new = $self->_parse_xml("$new");

  # Tree
  my $tree = $self->tree;

  # Root
  return $self if $tree->[0] eq 'root';

  # Parent
  my $parent = $tree->[3];

  # Siblings
  my @new;
  for my $e (@$new[1 .. $#$new]) {
    $e->[3] = $parent if $e->[0] eq 'tag';
    push @new, $e;
  }

  # Find
  my $i = $parent->[0] eq 'root' ? 1 : 4;
  for my $e (@$parent[$i .. $#$parent]) {
    last if $e == $tree;
    $i++;
  }

  # Add
  splice @$parent, $i + $offset, 0, @new;

  return $self;
}

# "Woah! God is so in your face!
#  Yeah, he's my favorite fictional character."
sub _cdata {
  my ($self, $cdata, $current) = @_;

  # Append
  push @$$current, ['cdata', $cdata];
}

sub _close {
  my ($self, $current, $pattern, $stop) = @_;

  # Default to table pattern
  $pattern ||= qr/^(col|colgroup|tbody|td|th|thead|tr)$/;

  # Default to table tag
  $stop ||= 'table';

  # Check parents
  my $parent = $$current;
  while ($parent) {
    last if $parent->[0] eq 'root' || $parent->[1] eq $stop;

    # Match
    ($parent->[1] =~ $pattern) and $self->_end($1, $current);

    # Next
    $parent = $parent->[3];
  }
}

sub _comment {
  my ($self, $comment, $current) = @_;

  # Append
  push @$$current, ['comment', $comment];
}

sub _css_equation {
  my ($self, $equation) = @_;
  my $num = [1, 1];

  # "even"
  if ($equation eq 'even') { $num = [2, 2] }

  # "odd"
  elsif ($equation eq 'odd') { $num = [2, 1] }

  # Equation
  elsif ($equation =~ /(?:(\-?(?:\d+)?)?(n))?\s*\+?\s*(\-?\s*\d+)?\s*$/) {
    $num->[0] = $1;
    $num->[0] = $2 ? 1 : 0 unless defined($num->[0]) && length($num->[0]);
    $num->[0] = -1 if $num->[0] eq '-';
    $num->[1] = $3 || 0;
    $num->[1] =~ s/\s+//g;
  }

  return $num;
}

sub _css_regex {
  my ($self, $op, $value) = @_;

  # Shortcut
  return unless $value;

  # Quote
  $value = quotemeta $self->_css_unescape($value);

  # Regex
  my $regex;

  # "~=" (word)
  if ($op eq '~') { $regex = qr/(?:^|.*\s+)$value(?:\s+.*|$)/ }

  # "*=" (contains)
  elsif ($op eq '*') { $regex = qr/$value/ }

  # "^=" (begins with)
  elsif ($op eq '^') { $regex = qr/^$value/ }

  # "$=" (ends with)
  elsif ($op eq '$') { $regex = qr/$value$/ }

  # Everything else
  else { $regex = qr/^$value$/ }

  return $regex;
}

sub _css_unescape {
  my ($self, $value) = @_;

  # Remove escaped newlines
  $value =~ s/\\\n//g;

  # Unescape unicode characters
  $value =~ s/\\([0-9a-fA-F]{1,6})\s?/pack('U', hex $1)/gex;

  # Remove backslash
  $value =~ s/\\//g;

  return $value;
}

sub _doctype {
  my ($self, $doctype, $current) = @_;

  # Append
  push @$$current, ['doctype', $doctype];
}

sub _end {
  my ($self, $end, $current) = @_;

  # Root
  return if $$current->[0] eq 'root';

  # Walk backwards
  my $next = $$current;
  while ($$current = $next) {

    # Root
    last if $$current->[0] eq 'root';

    # Next
    $next = $$current->[3];

    # Match
    if ($end eq $$current->[1]) { return $$current = $$current->[3] }

    # Autoclose optional HTML tags
    else {

      # Optional tags
      if ($$current->[1] =~ $HTML_AUTOCLOSE_RE) {
        $self->_end($$current->[1], $current);
        next;
      }

      # Table
      elsif ($end eq 'table') {
        $self->_close($current);
        next;
      }
    }

    # Children to move to parent
    my @buffer = splice @$$current, 4;

    # Update parent reference
    for my $e (@buffer) {
      $e->[3] = $next if $e->[0] eq 'tag';
      weaken $e->[3];
    }

    # Move children
    push @$next, @buffer;
  }
}

sub _match_element {
  my ($self, $candidate, $selectors) = @_;

  # Selectors
  my @selectors = reverse @$selectors;

  # Match
  my $first = 2;
  my ($current, $marker, $snapback);
  my $parentonly = 0;
  my $siblings;
  for (my $i = 0; $i <= $#selectors; $i++) {
    my $selector = $selectors[$i];

    # Combinator
    $parentonly-- if $parentonly > 0;
    if ($selector->[0] eq 'combinator') {

      # Combinator
      my $c = $selector->[1];

      # Parent only ">"
      if ($c eq '>') {
        $parentonly += 2;
        $marker   = $i - 1   unless defined $marker;
        $snapback = $current unless $snapback;
      }

      # Preceding siblings "~" and "+"
      elsif ($c eq '~' || $c eq '+') {
        my $parent = $current->[3];
        my $start = $parent->[0] eq 'root' ? 1 : 4;
        $siblings = [];

        # Siblings
        for my $i ($start .. $#$parent) {
          my $sibling = $parent->[$i];
          next unless $sibling->[0] eq 'tag';

          # Reached current
          if ($sibling eq $current) {
            @$siblings = ($siblings->[-1]) if $c eq '+';
            last;
          }
          push @$siblings, $sibling;
        }
      }

      # Move on
      next;
    }

    # Walk backwards
    while (1) {
      $first-- if $first != 0;

      # Next sibling
      if ($siblings) {

        # Last sibling
        unless ($current = shift @$siblings) {
          $siblings = undef;
          return;
        }
      }

      # Next parent
      else {
        return
          unless $current = $current ? $current->[3] : $candidate;
      }

      # Root
      return if $current->[0] ne 'tag';

      # Compare part to element
      if ($self->_match_selector($selector, $current)) {
        $siblings = undef;
        last;
      }

      # First selector needs to match
      return if $first;

      # Parent only
      if ($parentonly) {
        $i        = $marker - 1;
        $current  = $snapback;
        $snapback = undef;
        $marker   = undef;
        last;
      }
    }
  }

  return 1;
}

sub _match_selector {
  my ($self, $selector, $current) = @_;

  # Selectors
  for my $c (@$selector[1 .. $#$selector]) {
    my $type = $c->[0];

    # Tag
    if ($type eq 'tag') {
      my $type = $c->[1];

      # Wildcard
      next if $type eq '*';

      # Type (ignore namespace prefix)
      next if $current->[1] =~ /(?:^|\:)$type$/;
    }

    # Attribute
    elsif ($type eq 'attribute') {
      my $key   = $c->[1];
      my $regex = $c->[2];
      my $attrs = $current->[2];

      # Find attributes (ignore namespace prefix)
      my $found = 0;
      for my $name (keys %$attrs) {
        if ($name =~ /\:?$key$/) {
          ++$found and last
            if !$regex || ($attrs->{$name} || '') =~ /$regex/;
        }
      }
      next if $found;
    }

    # Pseudo class
    elsif ($type eq 'pseudoclass') {
      my $class = $c->[1];
      my $args  = $c->[2];

      # "first-*"
      if ($class =~ /^first\-(?:(child)|of-type)$/) {
        $class = defined $1 ? 'nth-child' : 'nth-of-type';
        $args = 1;
      }

      # "last-*"
      elsif ($class =~ /^last\-(?:(child)|of-type)$/) {
        $class = defined $1 ? 'nth-last-child' : 'nth-last-of-type';
        $args = '-n+1';
      }

      # ":checked"
      if ($class eq 'checked') {
        my $attrs = $current->[2];
        next if ($attrs->{checked}  || '') eq 'checked';
        next if ($attrs->{selected} || '') eq 'selected';
      }

      # ":empty"
      elsif ($class eq 'empty') { next unless exists $current->[4] }

      # ":root"
      elsif ($class eq 'root') {
        if (my $parent = $current->[3]) {
          next if $parent->[0] eq 'root';
        }
      }

      # "not"
      elsif ($class eq 'not') {
        next unless $self->_match_selector($args, $current);
      }

      # "nth-*"
      elsif ($class =~ /^nth-/) {

        # Numbers
        $args = $c->[2] = $self->_css_equation($args)
          unless ref $args;

        # Parent
        my $parent = $current->[3];

        # Siblings
        my $start = $parent->[0] eq 'root' ? 1 : 4;
        my @siblings;
        my $type = $class =~ /of-type$/ ? $current->[1] : undef;
        for my $j ($start .. $#$parent) {
          my $sibling = $parent->[$j];
          next unless $sibling->[0] eq 'tag';
          next if defined $type && $type ne $sibling->[1];
          push @siblings, $sibling;
        }

        # Reverse
        @siblings = reverse @siblings if $class =~ /^nth-last/;

        # Find
        my $found = 0;
        for my $i (0 .. $#siblings) {
          my $result = $args->[0] * $i + $args->[1];
          next if $result < 1;
          last unless my $sibling = $siblings[$result - 1];
          if ($sibling eq $current) {
            $found = 1;
            last;
          }
        }
        next if $found;
      }

      # "only-*"
      elsif ($class =~ /^only-(?:child|(of-type))$/) {
        my $type = $1 ? $current->[1] : undef;

        # Parent
        my $parent = $current->[3];

        # Siblings
        my $start = $parent->[0] eq 'root' ? 1 : 4;
        for my $j ($start .. $#$parent) {
          my $sibling = $parent->[$j];
          next unless $sibling->[0] eq 'tag';
          next if $sibling eq $current;
          next if defined $type && $sibling->[1] ne $type;
          return if $sibling ne $current;
        }

        # No siblings
        next;
      }
    }

    return;
  }

  return 1;
}

sub _match_tree {
  my ($self, $tree, $pattern) = @_;

  # Walk tree
  my @results;
  my @queue = ($tree);
  while (my $current = shift @queue) {

    # Type
    my $type = $current->[0];

    # Root
    if ($type eq 'root') {

      # Fill queue
      unshift @queue, @$current[1 .. $#$current];
      next;
    }

    # Tag
    elsif ($type eq 'tag') {

      # Fill queue
      unshift @queue, @$current[4 .. $#$current];

      # Parts
      for my $part (@$pattern) {

        # Match
        push(@results, $current) and last
          if $self->_match_element($current, $part);
      }
    }
  }

  # Upgrade results
  @results =
    map { $self->new(charset => $self->charset, tree => $_) } @results;

  # Collection
  return bless \@results, 'Mojo::DOM::_Collection';
}

sub _parse_css {
  my ($self, $css) = @_;

  # Tokenize
  my $pattern = [[]];
  while ($css =~ /$CSS_TOKEN_RE/g) {
    my $separator  = $1;
    my $element    = $2;
    my $pc         = $3;
    my $attributes = $4;
    my $combinator = $5;

    # Trash
    next
      unless $separator || $element || $pc || $attributes || $combinator;

    # New selector
    push @$pattern, [] if $separator;

    # Part
    my $part = $pattern->[-1];

    # Selector
    push @$part, ['element'];
    my $selector = $part->[-1];

    # Element
    $element ||= '';
    my $tag = '*';
    $element =~ s/$CSS_ELEMENT_RE// and $tag = $self->_css_unescape($1);

    # Tag
    push @$selector, ['tag', $tag];

    # Classes
    while ($element =~ /$CSS_CLASS_RE/g) {
      push @$selector, ['attribute', 'class', $self->_css_regex('~', $1)];
    }

    # ID
    if ($element =~ /$CSS_ID_RE/) {
      push @$selector, ['attribute', 'id', $self->_css_regex('', $1)];
    }

    # Pseudo classes
    while ($pc =~ /$CSS_PSEUDO_CLASS_RE/g) {

      # "not"
      if ($1 eq 'not') {
        my $subpattern = $self->_parse_css($2)->[-1]->[-1];
        push @$selector, ['pseudoclass', 'not', $subpattern];
      }

      # Everything else
      else { push @$selector, ['pseudoclass', $1, $2] }
    }

    # Attributes
    while ($attributes =~ /$CSS_ATTR_RE/g) {
      my $key   = $self->_css_unescape($1);
      my $op    = $2 || '';
      my $value = $3;
      $value = $4 unless defined $3;

      push @$selector, ['attribute', $key, $self->_css_regex($op, $value)];
    }

    # Combinator
    push @$part, ['combinator', $combinator] if $combinator;
  }

  return $pattern;
}

sub _parse_xml {
  my ($self, $xml) = @_;

  # State
  my $tree    = ['root'];
  my $current = $tree;

  # Decode
  my $charset = $self->charset;
  decode $charset, $xml if $charset && !utf8::is_utf8 $xml;
  return $tree unless $xml;

  # Tokenize
  while ($xml =~ m/\G$XML_TOKEN_RE/gcs) {
    my $text    = $1;
    my $pi      = $2;
    my $comment = $3;
    my $cdata   = $4;
    my $doctype = $5;
    my $tag     = $6;

    # Text
    if (length $text) {

      # Unescape
      html_unescape $text if (index $text, '&') >= 0;

      $self->_text($text, \$current);
    }

    # DOCTYPE
    if ($doctype) { $self->_doctype($doctype, \$current) }

    # Comment
    elsif ($comment) {
      $self->_comment($comment, \$current);
    }

    # CDATA
    elsif ($cdata) { $self->_cdata($cdata, \$current) }

    # Processing instruction
    elsif ($pi) { $self->_pi($pi, \$current) }

    next unless $tag;

    # End
    if ($tag =~ /$XML_END_RE/) {
      if (my $end = lc $1) { $self->_end($end, \$current) }
    }

    # Start
    elsif ($tag =~ /$XML_START_RE/) {
      my $start = lc $1;
      my $attr  = $2;

      # Attributes
      my $attrs = {};
      while ($attr =~ /$XML_ATTR_RE/g) {
        my $key   = $1;
        my $value = $2;
        $value = $3 unless defined $value;
        $value = $4 unless defined $value;

        # End
        next if $key eq '/';

        # Unescape
        html_unescape $value if $value && (index $value, '&') >= 0;

        # Merge
        $attrs->{$key} = $value;
      }

      # Start
      $self->_start($start, $attrs, \$current);

      # Empty tag
      $self->_end($start, \$current) if $attr =~ /\/\s*$/;

      # Relaxed "script" or "style"
      if ($start eq 'script' || $start eq 'style') {
        if ($xml =~ /\G(.*?)<\s*\/\s*$start\s*>/gcsi) {
          $self->_raw($1, \$current);
          $self->_end($start, \$current);
        }
      }
    }
  }

  return $tree;
}

sub _pi {
  my ($self, $pi, $current) = @_;

  # Append
  push @$$current, ['pi', $pi];
}

sub _raw {
  my ($self, $raw, $current) = @_;

  # Append
  push @$$current, ['raw', $raw];
}

sub _render {
  my ($self, $tree) = @_;

  # Element
  my $e = $tree->[0];

  # Text (escaped)
  if ($e eq 'text') {
    my $escaped = $tree->[1];
    xml_escape $escaped;
    return $escaped;
  }

  # Raw text
  return $tree->[1] if $e eq 'raw';

  # DOCTYPE
  return "<!DOCTYPE" . $tree->[1] . ">" if $e eq 'doctype';

  # Comment
  return "<!--" . $tree->[1] . "-->" if $e eq 'comment';

  # CDATA
  return "<![CDATA[" . $tree->[1] . "]]>" if $e eq 'cdata';

  # Processing instruction
  return "<?" . $tree->[1] . "?>" if $e eq 'pi';

  # Offset
  my $start = $e eq 'root' ? 1 : 2;

  # Content
  my $content = '';

  # Start tag
  if ($e eq 'tag') {

    # Offset
    $start = 4;

    # Open tag
    $content .= '<' . $tree->[1];

    # Attributes
    my @attrs;
    for my $key (sort keys %{$tree->[2]}) {
      my $value = $tree->[2]->{$key};

      # No value
      push @attrs, $key and next unless $value;

      # Escape
      xml_escape $value;

      # Key and value
      push @attrs, qq/$key="$value"/;
    }
    my $attrs = join ' ', @attrs;
    $content .= " $attrs" if $attrs;

    # Empty tag
    return "$content />" unless $tree->[4];

    # Close tag
    $content .= '>';
  }

  # Walk tree
  for my $i ($start .. $#$tree) {

    # Render next element
    $content .= $self->_render($tree->[$i]);
  }

  # End tag
  $content .= '</' . $tree->[1] . '>' if $e eq 'tag';

  return $content;
}

# "It's not important to talk about who got rich off of whom,
#  or who got exposed to tainted what..."
sub _start {
  my ($self, $start, $attrs, $current) = @_;

  # Autoclose optional HTML tags
  if ($$current->[0] ne 'root') {

    # Tag
    my $t = $$current->[1];

    # "<li>"
    if ($start eq 'li') { $self->_close($current, qr/^(li)$/, 'ul') }

    # "<p>"
    elsif ($t eq 'p' && $start =~ $HTML_PARAGRAPH_RE) {
      $self->_end('p', $current);
    }

    # "<head>"
    elsif ($t eq 'head' && $start eq 'body') { $self->_end('head', $current) }

    # "<optgroup>"
    elsif ($t eq 'optgroup' && $start eq 'optgroup') {
      $self->_end('optgroup', $current);
    }

    # "<option>"
    elsif ($t eq 'option' && ($start eq 'option' || $start eq 'optgroup')) {
      $self->_end('option', $current);
      $self->_end('optgroup', $current) if $start eq 'optgroup';
    }

    # "<colgroup>"
    elsif ($start eq 'colgroup') { $self->_close($current) }

    # "<thead>"
    elsif ($start eq 'thead') { $self->_close($current) }

    # "<tbody>"
    elsif ($start eq 'tbody') { $self->_close($current) }

    # "<tfoot>"
    elsif ($start eq 'tfoot') { $self->_close($current) }

    # "<tr>"
    elsif (($t eq 'tr' || $t eq 'td') && $start eq 'tr') {
      $self->_end('tr', $current);
    }

    # "<th>" and "<td>"
    elsif (($t eq 'th' || $t eq 'td') && ($start eq 'th' || $start eq 'td')) {
      $self->_end($t, $current);
    }

    # "<dt>" and "<dd>"
    elsif (($t eq 'dt' || $t eq 'dd') && ($start eq 'dt' || $start eq 'dd')) {
      $self->_end($t, $current);
    }

    # "<rt>" and "<rp>"
    elsif (($t eq 'rt' || $t eq 'rp') && ($start eq 'rt' || $start eq 'rp')) {
      $self->_end($t, $current);
    }
  }

  # New
  my $new = ['tag', $start, $attrs, $$current];
  weaken $new->[3];

  # Append
  push @$$current, $new;
  $$current = $new;
}

sub _text {
  my ($self, $text, $current) = @_;

  # Append
  push @$$current, ['text', $text];
}

package Mojo::DOM::_Collection;

sub each  { shift->_iterate(@_) }
sub until { shift->_iterate(@_, 1) }
sub while { shift->_iterate(@_, 0) }

sub _iterate {
  my ($self, $cb, $cond) = @_;

  # Shortcut
  return @$self unless $cb;

  # Iterator
  my $i = 1;

  # Iterate until condition is true
  if (defined $cond) { !!$_->$cb($i++) == $cond && last for @$self }

  # Iterate over all elements
  else { $_->$cb($i++) for @$self }

  # Root
  return unless my $start = $self->[0];
  return $start->root;
}

1;
__END__

=head1 NAME

Mojo::DOM - Minimalistic XML/HTML5 DOM Parser With CSS3 Selectors

=head1 SYNOPSIS

  use Mojo::DOM;

  # Parse
  my $dom = Mojo::DOM->new;
  $dom->parse('<div><div id="a">A</div><div id="b">B</div></div>');

  # Find
  my $b = $dom->at('#b');
  print $b->text;

  # Iterate
  $dom->find('div[id]')->each(sub { print shift->text });

  # Loop
  for my $e ($dom->find('div[id]')->each) {
    print $e->text;
  }

  # Get the first 10 links
  $dom->find('a[href]')
    ->while(sub { print shift->attrs->{href} && pop() < 10 });

  # Search for a link about a specific topic
  $dom->find('a[href]')
    ->until(sub { $_->text =~ m/kraih/ && print $_->attrs->{href} });

=head1 DESCRIPTION

L<Mojo::DOM> is a minimalistic and very relaxed XML/HTML5 DOM parser with
support for CSS3 selectors.
It will even try to interpret broken XML, so you should not use it for
validation.

=head1 SELECTORS

All CSS3 selectors that make sense for a standalone parser are supported.

=head2 C<*>

Any element.

  my $first = $dom->at('*');

=head2 C<E>

An element of type C<E>.

  my $title = $dom->at('title');

=head2 C<E[foo]>

An C<E> element with a C<foo> attribute.

  my $links = $dom->find('a[href]');

=head2 C<E[foo="bar"]>

An C<E> element whose C<foo> attribute value is exactly equal to C<bar>.

  my $fields = $dom->find('input[name="foo"]');

=head2 C<E[foo~="bar"]>

An C<E> element whose C<foo> attribute value is a list of
whitespace-separated values, one of which is exactly equal to C<bar>.

  my $fields = $dom->find('input[name~="foo"]');

=head2 C<E[foo^="bar"]>

An C<E> element whose C<foo> attribute value begins exactly with the string
C<bar>.

  my $fields = $dom->find('input[name^="f"]');

=head2 C<E[foo$="bar"]>

An C<E> element whose C<foo> attribute value ends exactly with the string
C<bar>.

  my $fields = $dom->find('input[name$="o"]');

=head2 C<E[foo*="bar"]>

An C<E> element whose C<foo> attribute value contains the substring C<bar>.

  my $fields = $dom->find('input[name*="fo"]');

=head2 C<E:root>

An C<E> element, root of the document.

  my $root = $dom->at(':root');

=head2 C<E:checked>

A user interface element C<E> which is checked (for instance a radio-button
or checkbox).

  my $input = $dom->at(':checked');

=head2 C<E:empty>

An C<E> element that has no children (including text nodes).

  my $empty = $dom->find(':empty');

=head2 C<E:nth-child(n)>

An C<E> element, the C<n-th> child of its parent.

  my $third = $dom->at('div:nth-child(3)');
  my $odd   = $dom->find('div:nth-child(odd)');
  my $even  = $dom->find('div:nth-child(even)');
  my $top3  = $dom->find('div:nth-child(-n+3)');

=head2 C<E:nth-last-child(n)>

An C<E> element, the C<n-th> child of its parent, counting from the last one.

  my $third    = $dom->at('div:nth-last-child(3)');
  my $odd      = $dom->find('div:nth-last-child(odd)');
  my $even     = $dom->find('div:nth-last-child(even)');
  my $bottom3  = $dom->find('div:nth-last-child(-n+3)');

=head2 C<E:nth-of-type(n)>

An C<E> element, the C<n-th> sibling of its type.

  my $third = $dom->at('div:nth-of-type(3)');
  my $odd   = $dom->find('div:nth-of-type(odd)');
  my $even  = $dom->find('div:nth-of-type(even)');
  my $top3  = $dom->find('div:nth-of-type(-n+3)');

=head2 C<E:nth-last-of-type(n)>

An C<E> element, the C<n-th> sibling of its type, counting from the last one.

  my $third    = $dom->at('div:nth-last-of-type(3)');
  my $odd      = $dom->find('div:nth-last-of-type(odd)');
  my $even     = $dom->find('div:nth-last-of-type(even)');
  my $bottom3  = $dom->find('div:nth-last-of-type(-n+3)');

=head2 C<E:first-child>

An C<E> element, first child of its parent.

  my $first = $dom->at('div p:first-child');

=head2 C<E:last-child>

An C<E> element, last child of its parent.

  my $last = $dom->at('div p:last-child');

=head2 C<E:first-of-type>

An C<E> element, first sibling of its type.

  my $first = $dom->at('div p:first-of-type');

=head2 C<E:last-of-type>

An C<E> element, last sibling of its type.

  my $last = $dom->at('div p:last-of-type');

=head2 C<E:only-child>

An C<E> element, only child of its parent.

  my $lonely = $dom->at('div p:only-child');

=head2 C<E:only-of-type>

an C<E> element, only sibling of its type.

  my $lonely = $dom->at('div p:only-of-type');

=head2 C<E:not(s)>

An C<E> element that does not match simple selector C<s>.

  my $others = $dom->at('div p:not(:first-child)');

=head2 C<E F>

An C<F> element descendant of an C<E> element.

  my $headlines = $dom->find('div h1');

=head2 C<E E<gt> F>

An C<F> element child of an C<E> element.

  my $headlines = $dom->find('html > body > div > h1');

=head2 C<E + F>

An C<F> element immediately preceded by an C<E> element.

  my $second = $dom->find('h1 + h2');

=head2 C<E ~ F>

An C<F> element preceded by an C<E> element.

  my $second = $dom->find('h1 ~ h2');

=head2 C<E, F, G>

Elements of type C<E>, C<F> and C<G>.

  my $headlines = $dom->find('h1, h2, h3');

=head2 C<E[foo=bar][bar=baz]>

An C<E> element whose attributes match all following attribute selectors.

  my $links = $dom->find('a[foo^="b"][foo$="ar"]');

=head1 ATTRIBUTES

L<Mojo::DOM> implements the following attributes.

=head2 C<charset>

  my $charset = $dom->charset;
  $dom        = $dom->charset('UTF-8');

Charset used for decoding and encoding XML.

=head2 C<tree>

  my $array = $dom->tree;
  $dom      = $dom->tree(['root', ['text', 'lalala']]);

Document Object Model.

=head1 METHODS

L<Mojo::DOM> inherits all methods from L<Mojo::Base> and implements the
following new ones.

=head2 C<add_after>

  $dom = $dom->add_after('<p>Hi!</p>');

Add after element.

  $dom->parse('<div><h1>A</h1></div>')->at('h1')->add_after('<h2>B</h2>');

=head2 C<add_before>

  $dom = $dom->add_before('<p>Hi!</p>');

Add before element.

  $dom->parse('<div><h2>A</h2></div>')->at('h2')->add_before('<h1>B</h1>');

=head2 C<all_text>

  my $text = $dom->all_text;

Extract all text content from DOM structure.

=head2 C<at>

  my $result = $dom->at('html title');

Find a single element with CSS3 selectors.

=head2 C<attrs>

  my $attrs = $dom->attrs;
  my $foo   = $dom->attrs('foo');
  $dom      = $dom->attrs({foo => 'bar'});
  $dom      = $dom->attrs(foo => 'bar');

Element attributes.

=head2 C<children>

  my $children = $dom->children;

Children of element.

=head2 C<find>

  my $collection = $dom->find('html title');

Find elements with CSS3 selectors and return a collection.

  print $dom->find('div')->[23]->text;
  $dom->find('div')->each(sub { print shift->text });
  $dom->find('div')->while(sub { print $_->text && $_->text =~ /foo/ });
  $dom->find('div')->until(sub { $_->text =~ /foo/ && print $_->text });

=head2 C<inner_xml>

  my $xml = $dom->inner_xml;

Render content of this element to XML.

=head2 C<namespace>

  my $namespace = $dom->namespace;

Element namespace.

=head2 C<parent>

  my $parent = $dom->parent;

Parent of element.

=head2 C<parse>

  $dom = $dom->parse('<foo bar="baz">test</foo>');

Parse XML document.

=head2 C<replace>

  $dom = $dom->replace('<div>test</div>');

Replace elements.

  $dom->parse('<div><h1>A</h1></div>')->at('h1')->replace('<h2>B</h2>');

=head2 C<replace_inner>

  $dom = $dom->replace_inner('test');

Replace element content.

  $dom->parse('<div><h1>A</h1></div>')->at('h1')->replace_inner('B');

=head2 C<root>

  my $root = $dom->root;

Find root element.

=head2 C<text>

  my $text = $dom->text;

Extract text content from element only, not including child elements.

=head2 C<to_xml>

  my $xml = $dom->to_xml;

Render DOM to XML.

=head2 C<type>

  my $type = $dom->type;
  $dom     = $dom->type('html');

Element type.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
