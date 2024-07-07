#vim: fdm=syntax et
# encoding: utf-8
# frozen_string_literal: true
# ------------------------------------------------------------------------
# Copyright: 2024- Emanuele Caratti
# ------------------------------------------------------------------------

require 'rubygems/version'

module WU
  class SemVer < Gem::Version #{{{1
    include Comparable
    # RE {{{2
    SEM_VER_RE = /
      (?<ver>
        (?<rel>
         (?<maj>\d+) \.
         (?<min>\d+)
        )
        (?: 
          \. (?<patch>\d+)
          (?<extra>
            (?: . \d+)*
            (?: (?: [-_] r (?<pkgrel> \d+ ) ) | 
                (?:- [a-zA-Z0-9]+)
            )?
          )?
        )?
      )/x.freeze

    SEM_VER_RE_A = /^#{SEM_VER_RE}$/.freeze

    # }}}2

    RE_FIELDS = 9
    private_constant :RE_FIELDS
    def self.num_fields #{{{2
      RE_FIELDS
    end #}}}2

    def self.create(...) ;super.freeze;end

    def self.correct?(version) #{{{2
      SEM_VER_RE_A.match?(version) || super
    end #}}}2

    def self.lowest #{{{2
      @lowest ||= self.allocate.tap{|lowest_ver|
        lowest_ver.instance_variable_set :@version, '-1'
        lowest_ver.instance_variable_set :@prerelease, false
        lowest_ver.instance_variable_set :@segments, (_seg = [-1].freeze)
        lowest_ver.instance_variable_set :@canonical_segments, _seg
      }.freeze
    end #}}}2

    def initialize(version) #{{{2
      @pkgrel = nil
      @orig_version = nil
      if (m = SEM_VER_RE_A.match(version)) && m[:pkgrel] 
        @pkgrel = Integer(m[:pkgrel])
        @orig_version = version.freeze
        version = version.sub(/[-_]r(\d+)$/, '.\1')  # convert the alpine pkg release to be a subpatch version
                                                  # this will allow compare to work as expected with Gem::Version
      end 
      super
      @version.freeze
    end #}}}2

    def lowest? #{{{2
      @version == '-1'
    end #}}}2

    def to_s #{{{2
      @orig_version || @version
    end #}}}2

    def same_minor?(oth) #{{{2
      return nil unless oth.kind_of? Gem::Version
      segments[0] == oth.segments[0] && 
        segments[1] == oth.segments[1]
    end #}}}2

    def same_major?(oth) #{{{2
      return nil unless oth.kind_of? Gem::Version
      segments[0] == oth.segments[0]
    end #}}}2
  end #}}}1
end

