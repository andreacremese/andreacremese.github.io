# My mental model and a few ideas on LLM models

**Language Model** a probabilitist computational model that predicts sequence in natural lanugage.

Each passage is a transformation to / from a vectorial space.

## Embedding / unembedding into / from the model dimension

Translate from a token (similar to a word) into a vector in a multi space (not 3). 
This part is deterministic, but it still involves a model of sorts. The bank in river bank and the Gringotts bank have the same
vectorial representation after embedding.

This is not to be confused with **encoding**. The encoder runs these vectors through blocks of attention and MLP layers to produce
an enriched representation.

### A small bit on vectorial spaces

Each direciton in a vectorial space can be classified as a concept (blue, raining, horse, queen) but also distances can
be classified as vectors. meaing (queen - king) ~ (man - woman) [within reason]. So the ideas is that you can "
travel" vectors with the meaning from other vectors.

## Attention

This is the part that allows words to "talk" to each other. E.g.

> the white swan in the blue water.

As an idea, this is the part that attributes the adjective "blue" to "water" and "white" to "swan".
This part is not necessarily (and likely not at all) in the same vectorial space as the model dimension, but it is a 
linear transformation to got to and from these. Different heads get trained for different operations (syntax, coherence, ...)

The output of a head here is a vector that is the sum of the original vector PLUS the output of the attention. The idea
is that the attention lets you "travel" the vector in the vectorial space by the amount of a concept.

## Multi Layer Perceptron

This is the part that adds to the knowledge

> Michael Jordan plays...

The paramns in here add the vector that will map to "basketball".


## Blocks and heads

A model has multiple blocks, they act in series, the output of each block is the input of the next one over.

A blok has multiple heads (with the attention) and a single MLP layer.
Each head gets a subset of the total dimension, and is trained on that dimension. Heads run in parallel, and get concatenated
before getting in the MLP, going back to the full dimension of the model.

## Encoder VS Decoder

Encoder lets all tokens being available to attend to the current token, so it is ideal for classification, understanding.

Decoder lets only the previous tokens to attend to the current token, and that is needed for generation.

The original architecture has both, as it was needed for translation. BERT style architecture have only encoders,  GPT has only decoder.


## Tokenization, Encoding

Turn a word, subword, character into an integer. Later this will be turned into a vector.



## Expansions

- Karpathy https://youtu.be/kCc8FmEb1nY?si=T1N1i8k1B8sxPl-x
  architecture rather than just recognizing it.
2. "Attention Is All You Need" (Vaswani et al., 2017) — the original paper. It's short (~15 pages), the diagrams are clear, and Section 3 maps directly to what you already know. Worth one read now that you have
  the mental model.
3. BERT paper (Devlin et al., 2018) — Section 3.1 (pre-training tasks) explains the MLM vs next-sentence prediction clearly. Skim the rest.
4. "Language Models are Few-Shot Learners" (GPT-3, Brown et al., 2020) — mostly skip to Section 2 for the architecture and training setup. The rest is about prompting, which you already understand operationally.

  Karpathy's video is the one I'd prioritize — it will make the BERT/GPT distinction visceral rather than abstract.
- encoder / decoder
- more on the model dimension
- experiments in vectorial spaces
- embedding The word "embedding" is doing double duty in the industry:
  1. The input lookup table (precise ML term)
  2. The output of an encoder model (common production usage)




## Berst VS Gpt VS OG Transformer T5

Original Transformer (2017):
┌─────────────┐
│   Encoder   │ ← Bidirectional
│  (6 layers) │
└──────┬──────┘
       │
┌──────▼──────┐
│   Decoder   │ ← Causal + Cross-attention
│  (6 layers) │
└─────────────┘

BERT (2018):
┌─────────────┐
│   Encoder   │ ← Bidirectional
│ (12 layers) │
└─────────────┘
(Encoder-Only)

GPT (2018):
┌─────────────┐
│   Decoder   │ ← Causal only (no cross-attn)
│ (12 layers) │
└─────────────┘
(Decoder-Only)
