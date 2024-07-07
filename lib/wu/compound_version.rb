#vim: fdm=syntax et
# encoding: utf-8
# frozen_string_literal: true
# ------------------------------------------------------------------------
# Copyright: 2024- Emanuele Caratti
# ------------------------------------------------------------------------

require_relative 'sem_ver'

module WU
  class CompoundVersion #{{{1
    include Comparable

    # RE #{{{2
    TAG_RE   = /[A-Za-z0-9_][A-Za-z0-9_.-]*/.freeze
    TAG_RE_A = /^#{TAG_RE}$/.freeze

    # }}}2

    module GemVersion #{{{2
      def <=>(other) #{{{3
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

    def self.valid_tag?(tag) #{{{2
      tag.nil? || TAG_RE_A.match?(tag)
    end #}}}2
    
    protected attr_reader :versions
    # @param [String, Gem::Version, Array<String,String|Gem::Version>, Hash<String,String|Gem::Version>] ver version(s) to use
    # @param [Array<Symbol,String>] :tags, explicit order of tags. Nil is always the first
    def initialize(ver=nil, untagged: nil, tags: nil) #{{{2
      @tags_order = tags || []
      @tags_order.freeze
      @untagged = untagged
      @versions = {}

      add_versions ver if ver
    end #}}}2

    def valid_tag?(tag)   ; self.class.valid_tag?(tag); end

    # Return all tags for for the versions, first may be nil if version is untagged
    # @return [Array<Symbol>]
    def tags #{{{2
      @tags_order.map{|_t|
        _t == @untagged ? nil : _t
      }
    end #}}}2

    def same_minor?(oth) #{{{2
      @tags_order.all?{|_t|
        @versions[_t].same_minor?(oth.versions[_t])
      }
    end #}}}2

    def same_minor_map(oth) #{{{2
      @tags_order.map{|_t|
        [ @versions[_t], oth.versions[_t], @versions[_t].same_minor?(oth.versions[_t]) ]
      }
    end #}}}2

    def same_major?(oth) #{{{2
      @tags_order.all?{|_t|
        @versions[_t].same_major?(oth.versions[_t])
      }
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

    def hash # :nodoc #{{{2
      @versions.hash 
    end #}}}2

    def eql?(oth) #{{{2
      return nil unless oth.kind_of?(self.class)
      oth.equal?(self) || (
                       @versions.eql?(oth.versions) &&
                       @tags_order.eql?(oth.instance_variable_get(:@tags_order)) &&
                       @untagged.eql?(oth.instance_variable_get(:@untagged))
      )
    end

    def regexp #{{{2
      @regexp ||= (
        Regexp.new( '^(' + @tags_order.map.with_index{|_tag, _i|
          "(?<#{_tag || '_untagged_'}>(?<tag#{_i}>#{_tag})#{WU::SemVer::SEM_VER_RE.source})"
        }.join('-') + ')$', Regexp::EXTENDED )
      ) 
    end #}}}2

    def correct?(str) #{{{2
      regexp.match?(str)
    end #}}}2

    def clear! #{{{2
      @versions.clear 
      self 
    end #}}}2

    def parse(str) #{{{2
      self.clone(freeze: false)
        .clear!
        .parse!(str)
    end #}}}2

    # @option [Hash] kwopts
    # @option kwopts [Symbol] :untagged used to speficy new untagged, if needed.
    def slice(*tags, **kwopts, &on_not_found) #{{{2
      blk = if on_not_found
              Proc.new do |_key|
                yield _key, self
              end
            end

      self.class.new tags.each_with_object({}){|_t,_acc|
        _acc[_t] = @versions.fetch(_t, &blk)
      }, untagged: kwopts.fetch(:untagged, @untagged)
    end #}}}2

    def set_lowest_version #{{{2
      self.clone(freeze: false)
        .set_lowest_version!
    end #}}}2

    def lowest? #{{{2
      @versions.any?(&:lowest?)
    end #}}}2

    def set_lowest_version! #{{{2
      @versions.transform_values!{WU::SemVer.lowest}
      self
    end

    def freeze #{{{2
      @versions.freeze
      regexp
      super
    end #}}}2

    def parse!(str) #{{{2
      if m = regexp.match(str)
        m.captures.each_slice(WU::SemVer.num_fields) do |_full, tag, ver, _rel, _maj, _min, _patch, _extra, _pkgrel|
          tag = nil if tag == ''
          add ver, tag: tag
        end
        self
      end
    end #}}}2

    def to_s #{{{2
      @tags_order.each_with_object([]){|_tag, _acc|
        next unless _ver = @versions[_tag]
        _acc << %Q|#{_tag}#{_ver}|
      }.join('-')
    end #}}}2

    def add(ver, tag: nil) #{{{2
      raise ArgumentError, "Invalid tag #{String === _tag ? _tag : _tag.class}" unless valid_tag?(tag)
      tag = tag&.to_sym
      @versions[tag] =  WU::SemVer.create(ver)
      unless @tags_order.include?(tag)
        @tags_order = @tags_order.dup.send(tag.nil? ? :unshift : :push,tag).freeze 
        @regexp = nil
      end
      self
    end #}}}2

    def add?(ver, tag: nil) #{{{2
      return nil unless @tags_order.include?(tag)
      add ver, tag: tag
      self
    end #}}}2

    def add!(ver, tag: nil) #{{{2
      raise RuntimeError, "Tag not Found: #{tag.inspect}" unless @tags_order.include?(tag)
      add ver, tag: tag
    end #}}}2
    # @param [String, Gem::Version, Array<String,String|Gem::Version>, Hash<String,String|Gem::Version>] ver version(s) to use
    # @return self
    def add_versions(ver) #{{{2
      case ver
      when String, Gem::Version #WU::SemVer::SEM_VER_RE_A
        add ver, tag: nil
      when Hash, Array
        ver.each_with_index do |(_tag, _ver),_i|
          _ver, _tag = _tag, nil unless _ver
          _tag = nil if _tag == @untagged
          _parsed_ver = WU::SemVer.create(_ver)
          if _tag.nil?
            if _i == 0
              add _parsed_ver, tag: nil
            else
              raise RuntimeError, "Nil tag must be the first #{_ver}"
            end
          else
            add _parsed_ver, tag: _tag
          end
        end
      else
        raise ArgumentError, "Invalid version #{ver.class}"
      end
      return self
    end #}}}2

    def initialize_copy(orig) #{{{2
      super
      @versions = @versions.dup
    end #}}}2
  end #}}}1
end
