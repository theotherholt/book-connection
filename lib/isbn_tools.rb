#--
# Copyright 2006, Thierry Godfroid
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# * The name of the author may not be used to endorse or promote products derived
#   from this software without specific prior written permission.
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module ISBNTools # :nodoc: all
  class InvalidISBN < StandardError
    def initialize(message = "You entered an invalid ISBN.")
      super
    end
  end
  
  RANGES = {
    '0' => [ '00'..'19', '200'..'699', '7000'..'8499', '85000'..'89999', '900000'..'949999', '9500000'..'9999999' ],
    '1' => [ '00'..'09', '100'..'399', '4000'..'5499', '55000'..'86979', '869800'..'998999' ],
    '2' => [ '00'..'19', '200'..'349', '35000'..'39999', '400'..'699', '7000'..'8399', '84000'..'89999', '900000'..'949999', '9500000'..'9999999' ]
  }
  
  def self.cleanup(isbn)
    isbn.gsub(/[^0-9xX]/,'').gsub(/x/,'X') unless isbn.nil? || isbn.scan(/([xX])/).length > 1
  end
  
  def self.cleanup!(isbn)
    isbn.replace(cleanup(isbn))
  end
  
  def self.compute_isbn13_check_digit(isbn)
    return nil if isbn.nil? || isbn.length > 13 || isbn.length < 12
    sum = 0; 0.upto(11) { |i| sum += (isbn[i].chr.to_i * ((i % 2 == 0) ? 1 : 3)) }
    ((10 - sum.remainder(10)) == 10) ? '0' : (10 - sum.remainder(10)).to_s
  end
  
  def self.hyphenate_isbn13(isbn)
    isbn = cleanup(isbn)
    if is_valid_isbn13?(isbn)
      group = isbn[3..3]
      if RANGES.has_key?(group)
        RANGES[group].each do |range|
          return isbn.sub(Regexp.new("(.{3})(.{1})(.{#{range.last.length}})(.{#{8 - range.last.length}})(.)"), '\1-\2-\3-\4-\5') if range.member?(isbn[1..range.last.length])
        end
      end
    else
      return isbn
    end
  end
  
  def self.is_valid?(isbn)
    is_valid_isbn10?(isbn) || is_valid_isbn13?(isbn)
  end
  
  def self.is_valid_isbn10?(isbn)
    return false if isbn.nil? || isbn.match(/^[0-9]{9}[0-9X]$/).nil?
    sum = 0; 0.upto(9) { |i| sum += ((isbn[i] != 88) ? isbn[i].chr.to_i : 10) * (10 - i) }
    sum % 11 == 0
  end
  
  def self.is_valid_isbn13?(isbn)
    return false if isbn.nil? || isbn.length != 13 || isbn.match(/^97[8|9][0-9]{10}$/).nil?
    sum = 0; 0.upto(12) { |i| sum += (isbn[i].chr.to_i * ((i % 2 == 0) ? 1 : 3)) }
    sum.remainder(10) == 0
  end
  
  def self.isbn10_to_isbn13(isbn)
    '978' + isbn[0..8] + compute_isbn13_check_digit("978" + isbn[0..8]) unless isbn.nil? || !is_valid_isbn10?(isbn)
  end
  
  def self.normalize_isbn(isbn)
    return if isbn.nil?
    clean_isbn = cleanup(isbn)
    
    if is_valid_isbn10?(clean_isbn)
      return isbn10_to_isbn13(clean_isbn)
    elsif is_valid_isbn13?(clean_isbn)
      return clean_isbn
    else
      raise InvalidISBN
    end
  end
end
