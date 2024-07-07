#vim: fdm=syntax et
# encoding: utf-8
# frozen_string_literal: true
# ------------------------------------------------------------------------
# Copyright: 2024- Emanuele Caratti
# ------------------------------------------------------------------------

require 'rubygems/version'

module WU
  class CompoundVersion #{{{1
    include Comparable

    module GemVersion #{{{3
      def <=>(other)
        if other.kind_of?(::WU::CompoundVersion)
          compound_compare = other <=> self
          if compound_compare
            return compound_compare * -1
          else
            return compound_compare
          end
        end
        super
      end #}}}3
    end #}}}2

    Gem::Version.prepend GemVersion
    # RE #{{{2
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
            (?: [-_] [a-zA-Z0-9]+ )?
          )?
        )
      )/x.freeze

    SEM_VER_RE_A = /^#{SEM_VER_RE}$/.freeze

    TAG_RE   = /[A-Za-z0-9_][A-Za-z0-9_.-]*/.freeze
    TAG_RE_A = /^#{TAG_RE}$/.freeze

    # }}}2

    def self.parse_semver(str) #{{{2
      case str
      when SEM_VER_RE
        Gem::Version.new(str).freeze
      when Gem::Version
        str.frozen? ? str : str.dup.freeze
      when String
        warn "Invalid string #{str}"
        raise ArgumentError, "Invalid string #{str}"
      else
        warn "Invalid string #{str.class}"
        raise TypeError, "Invalid string #{str.class}"
      end
    end #}}}2
    
    protected attr_reader :versions
    # @param [String, Gem::Version, Array<String,String|Gem::Version>, Hash<String,String|Gem::Version>] ver version(s) to use
    def initialize(ver) #{{{2
      @versions = []

      add_versions ver
    end #}}}2

    # Return all tags for for the versions, first may be nil if version is untagged
    # @return [Array<Symbol>]
    def tags #{{{2
      @versions.map(&:first)
    end #}}}2

    def <=>(oth, first_untagged: nil) #{{{2
      return nil unless @versions.any?
      case oth
      when Gem::Version
        return nil if @versions[0][0] && !first_untagged
        @versions[0][1] <=> oth
      when self.class
        @versions.zip(oth.versions).each do |((_tag,_ver),(_oth_tag, _oth_ver))|
          if _tag != _oth_tag
            if _oth_tag.nil? # Can only be at the beginning, this is enforced on tag creation
              return 1
            else
              return nil 
            end
          end
          _cmp = _ver <=> _oth_ver
          return _cmp unless _cmp == 0
        end
        # Reach only if @versions is smaller than oth.versions or all versions are equal
        if @versions.size == oth.versions.size
          return 0
        else
          return -1
        end
      else
        return nil
      end
    end #}}}2

    def to_s #{{{2
      @versions.map{|_tag, _ver| %Q|#{_tag}#{_ver}|}.join('-')
    end #}}}2
    # @param [String, Gem::Version, Array<String,String|Gem::Version>, Hash<String,String|Gem::Version>] ver version(s) to use
    # @return self
    def add_versions(ver) #{{{2
      case ver
      when SEM_VER_RE_A
        @versions << [ nil, self.class.parse_semver(ver)]
      when Hash, Array
        ver.each_with_index do |(_tag, _ver),_i|
          _ver, _tag = _tag, nil unless _ver
          _parsed_ver = self.class.parse_semver(_ver)
          if _tag.nil?
            if _i == 0
              @versions << [nil, _parsed_ver] 
            else
              raise RuntimeError, "Nil tag must be the first #{_ver}"
            end
          elsif TAG_RE_A.match?(_tag)
            @versions << [ _tag.to_sym, _parsed_ver ].freeze
          else
            raise ArgumentError, "Invalid tag #{String === _tag ? _tag : _tag.class}"
          end
        end
      end
      return self
    end #}}}2
  end #}}}1
end
