- [Generate a 2-column html file for a bilingual reader.](#generate-a-2-column-html-file-for-a-bilingual-reader)
  * [Sample](#sample)
- [Generate Anki audio-only cards](#generate-anki-audio-only-cards)
  * [Assumptions / Pre-reqs](#assumptions---pre-reqs)
  * [Text file](#text-file)
  * [Sample](#sample-1)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


# Generate a 2-column html file for a bilingual reader.

Tools like (https://translate.google.ca/?sl=es&tl=en&op=docs)[Google translate] let you upload and translate documents.  I like the side-by-side-columns format of bilingual readers, and find it a hassle to switch between multiple documents when reading, so this quick script knits together two files to create a single html file with the paragraphs aligned correctly, e.g:

```
- You're Aladdin, the tailor's son, right?           – ¿Tú eres Aladino, el hijo del sastre, verdad?

- Yes, and it is true that my father was a tailor,   – Sí, y es cierto que mi padre era sastre, pero… ¿Quién es usted?
  but ... Who are you?
```

The paragraphs for both texts are guaranteed to line up.

## Sample

```
ruby cols.rb samples/aladino-eng.txt samples/aladino-esp.txt aladin.html
```

Then open the file aladin.html in your browser.

## Making texts

Various sites have text-only stories, e.g. https://www.mundoprimaria.com/cuentos-infantiles-cortos for Spanish.  Copy the full native text from the page to a local file, and use Google Translate or similar to generate the translation.  Lastly, use this utility to generate the html, and then you can read it as-is, or download a PDF.

# Generate Anki audio-only cards

_Note: this code is hacked together for my personal use, I haven't generalized it/made it configurable.  See the Assumptions below._

## Assumptions / Pre-reqs

* have Anki and AnkiConnect
* have an AWS account setup with appropriate keys
* `gem install aws-sdk`
* various `#Assumption` comments in `gen_audio_cards.rb`

## Text file

In `text` folder, put a file with L2 sentences on the top, a separator `---`, and L1 sentences on the bottom.

Run `ruby gen_audio_cards.rb`

The above will:

* generate L1 and L2 mp3 files using AWS Polly
* generate card data combining the L1 and L2 translations with their sound files
* post the cards to Anki using AnkiConnect
* move the processed file from `text` to `text-done`

## Sample

Copy the file in `samples` to the appropriate `text` folder (in this case, it's Spanish, so `text/esp`).

Run the program:

```
ruby gen_audio_cards.rb
```