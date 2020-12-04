# Tools

## Generate Anki audio-only cards

_Note: this code is hacked together for my personal use, I haven't generalized it/made it configurable.  See the Assumptions below._

### Assumptions / Pre-reqs

* have Anki and AnkiConnect
* have an AWS account setup with appropriate keys
* `gem install aws-sdk`
* various `#Assumption` comments in `gen_audio_cards.rb`

### Text file

In `text` folder, put a file with L2 sentences on the top, a separator `---`, and L1 sentences on the bottom.

Run `ruby gen_audio_cards.rb`

The above will:

* generate L1 and L2 mp3 files using AWS Polly
* generate card data combining the L1 and L2 translations with their sound files
* post the cards to Anki using AnkiConnect
* move the processed file from `text` to `text-done`

### Sample

Copy the file in `samples` to the appropriate `text` folder (in this case, it's Spanish, so `text/esp`).

Run the program:

```
ruby gen_audio_cards.rb
```