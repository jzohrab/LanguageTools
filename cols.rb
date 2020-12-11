# Make an html file using two inputs files, breaking on paragraphs.

def get_paragraphs(filename)
  f = File.
        read(filename).
        split("\n").
        select { |s| s.strip != '' }
end

def generate_html(pairs, outfile)

  lines = pairs.map do |pair|
    content = pair.map { |e| "<div class=\"col\">#{e}</div>\n" }
    "<div class=\"box\">\n#{content.join('')}</div>"
  end.join("\n")

  return "<html>
  <style>
    body { font-family: Helvetica; }
    .box { display: flex; }
    .col { width: 400px; padding: 10px; }
  </style>
  <body>
#{lines}
  </body>
</html>"

end

def get_pairs(file1, file2)
  p1 = get_paragraphs(file1)
  p2 = get_paragraphs(file2)
  countsMsg = "#{file1}: #{p1.size}; #{file2}: #{p2.size}"
  raise "Different paragraph count: #{countsMsg}" if p1.size != p2.size

  pairs = p1.zip(p2)
  # puts pairs.inspect

  pairs
end

file1, file2, file3 = ARGV

begin
  raise "Missing file 1" if file1.nil?
  raise "Missing file 2" if file2.nil?
  raise "Missing output file" if file3.nil?

  raise "No such file #{file1}" unless File.exist?(file1)
  raise "No such file #{file2}" unless File.exist?(file2)

  pairs = get_pairs(file1, file2)

  content = generate_html(pairs, file3)
  File.open(file3, 'w') { |f| f.puts content }
  puts "#{file3} generated."

rescue Exception => e
  puts "Error: #{e.message}"
end
