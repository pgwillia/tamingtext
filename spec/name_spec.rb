# name_spec.rb
require 'open-nlp'

describe "play with open-nlp" do
  before(:all) do
    OpenNLP.load
  end
  it "returns name from a sentence" do
    text = File.read('./spec/sample.txt').gsub!("\n", "")

    tokenizer   = OpenNLP::TokenizerME.new
    segmenter   = OpenNLP::SentenceDetectorME.new
    ner_models  = ['person', 'organization', 'location']

    ner_finders = ner_models.map do |model|
      OpenNLP::NameFinderME.new("en-ner-#{model}.bin")
    end

    sentences = segmenter.sent_detect(text)
    named_entities = []

    sentences.each do |sentence|

      tokens = tokenizer.tokenize(sentence)

      ner_models.each_with_index do |model,i|
        finder = ner_finders[i]
        name_spans = finder.find(tokens)
        name_spans.each do |name_span|
          start = name_span.get_start
          stop  = name_span.get_end-1
          slice = tokens[start..stop].to_a
          named_entities << [slice, model]
        end # end name_spans
      end # end ner_models
    end # end sentences
    expect( named_entities).to include([["Inspector", "Duncan"], "person"])
    expect( named_entities).to include([["John", "Jackson"], "person"])
    expect( named_entities).to include([["Toronto"], "location"])
    expect( named_entities).to include([["Union"], "organization"])
  end # end it
end

