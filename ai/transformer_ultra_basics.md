---
title: "Transformer Architecture: The Ultra Basics – May 2026"
subtitle: "A starter reference for how it all fits together"
date: 2026-05-08
layout: default
description: "A starter guide to the transformer architecture — enough to get the shape of vectorial spaces, embeddings, attention, MLP, and the encoder/decoder split."
---


## Introduction

This is a starter guide on how the transformer architecture works — a reference to come back to when I need to re-anchor on the fundamentals. Andrej Karpathy and 3Blue1Brown are my go-to sources here, and I've linked their key videos in the references.

**A caveat, for an engineer's mind:** as someone who got beaten over the head with linear algebra for many years in uni, my instinct is to fully understand each vectorial space and transformation (linear or otherwise) before moving to the next. That instinct will slow you down here. There are many spaces, many transformations between them, and they come hard and fast. My advice: get the shape of the architecture first, then revisit the details. It clicked for me once I started working with embedding models in practice for a RAG — not from staring at the math.

The one-line version: a language model is a probabilistic computational model that predicts sequences in natural language. Everything that follows is the machinery for how transformers do that — and it all happens in vectorial spaces.


## Vectorial Spaces

In the scope of LLMs and transformers, each direction in a vectorial space corresponds to a semantic feature (blue, raining, horse, queen). The difference between two points is a vector that carries meaning: (queen - king) ≈ (man - woman), *within reason*. The idea is that you can "travel" along vectors to move between related concepts — and this navigation is what the model does at every stage: embedding, attention, and generation.


## Embeddings

Embeddings turn each token (word or part of a word) into a vector in a dense multi-dimensional space. This is a constant-time lookup at inference — essentially a table mapping each token to its vector.

The positions in that space are not hand-designed. Nobody sat down and put "red" on direction [1,4,25,...]. They are learned during training, and different training runs produce different spaces. But once trained, the mapping is fixed: "cake" always gets the same vector.

One important limitation: embeddings are context-free. The "bank" in river bank and the "bank" in Gringotts bank get the same vector at this stage. Resolving that ambiguity is what attention does — but that comes later.

Not to be confused with the **encoder**, which runs these vectors through blocks of attention and MLP layers to produce context-enriched representations.


## Architecture Overview

Once tokens are embedded, they flow through stacked layers. The architecture comes in three flavors:

```
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
```

The original transformer has both an encoder and a decoder (more on their differences later). BERT kept only the encoder; GPT kept only the decoder. GPT-style models are **autoregressive** — they generate tokens one at a time by feeding each output back as input.

### Inside a Block

Each of those layers is a **block**, stacked in series — the output of one block is the input of the next. Each block has multiple **attention heads** and a single **MLP layer** (feed-forward neural network). This is straight from the original paper "Attention Is All You Need", where blocks are repeated N times.

Each head gets a subset of the total dimension from the embedded vector and is trained on those dimensions. Heads run in parallel, then get concatenated before entering the MLP — going back to the full dimension of the model. MLP runs in parallel across tokens, because there is no cross-token interaction in that step.


## Attention

This is the part that allows words to "talk" to each other. It computes the affinity between tokens and lets them communicate. E.g.:

> The white swan in the blue water.

After attention, "blue" is strongly associated with "water" and "white" with "swan." Each token's vector gets updated based on what it attended to.

The key mechanism: the output of an attention block is the original vector PLUS the attention output. Remember "traveling" along vectors from the Vectorial Spaces section? That's exactly what's happening — attention lets each token's vector travel in the direction of related concepts in the input. This is the residual connection.

This computation happens in a different vectorial space than the model dimension (a linear transformation projects in and out). Different heads get trained for different operations — syntax, coherence, semantic relationships.

### Query / Key / Value

Three matrices that drive the mechanism:

- **Query (Q)**: "what am I looking for?"
- **Key (K)**: "what do I have to offer?"
- **Value (V)**: "if you attend to me, here's what I actually give you"

They are combined as:

```
Attention(Q,K,V) = softmax(QKᵀ/√d_k)V
```

where d_k is the dimension of the key vectors (a normalization factor).

Q·Kᵀ computes how much each token wants to attend to every other token — we want "blue" and "water" to produce a high value here. The softmax turns these into weights. Then V determines *what* information actually flows back — not how much, but the content of the message. "Blue" may strongly attend to "water" (high Q·K score), but what "water" is broadcasting in this particular head (its V vector) may or may not be useful for what "blue" needs. Different heads learn different V projections — one head's "water" might broadcast semantic category, another might broadcast syntactic role.

### Attention Variants

- **Self attention** — Q, K, V all come from the same sequence. Tokens attend to each other within the same input.
- **Cross attention** — Q comes from the decoder, K and V from the encoder. This is how the decoder "queries" the encoder's representation.
- **Scaled attention** — the √d_k normalization in the formula above, preventing softmax from saturating towards a single token.
- **Masked attention** — zeroes out future tokens so the current token can only attend to previous ones. Key ingredient for autoregression in the decoder; you definitely don't want it in an encoder.

### A Note on "Matrices" vs "Vectors"

Q, K, and V can refer to matrices or vectors depending on context. W_Q, W_K, W_V are the learned **weight matrices** — the parameters that get trained. When applied to the full input sequence, they produce Q, K, V **matrices** (one row per token). When talking about a single token — e.g., "water's V vector" — that's one row after the projection. Same objects, different zoom level.


## Multi Layer Perceptron (Computation)

**This is where MOST of the parameters live** (so Attention is NOT all you need really =)). 3Blue1Brown calls this layer "where the LLM stores facts."

If attention determines *which* tokens are relevant to each other, the MLP adds *what the model knows* about those tokens. Consider:

> Michael Jordan plays...

The parameters in the MLP add the vector that pushes toward "basketball." It runs in parallel on each token independently, because there is no cross-token interaction at this stage.

Same as attention, the output is a residual connection: original vector + MLP output. The token keeps traveling through vectorial space, accumulating context from attention and knowledge from the MLP at each block.

### Project Up, Non-Linearity, Project Down

The MLP structure is: linear projection up to a wider dimension (~4x model size) → nonlinearity → linear projection back down to model dimension.

The projection up gives the model more room to represent features. The projection back down returns to model dimension so it can flow into the next block.

Why the nonlinearity in the middle? Without it, stacking two linear layers does nothing — matrix multiplication is associative, so `(xW₁)W₂ = x(W₁W₂)`, which collapses into a single linear transformation. The whole up-and-down structure would be an expensive way to multiply by one matrix.

The nonlinearity (ReLU in the original paper, modern models have more refined systems, but the idea is the same) is what makes two layers worth having. Don't let the term scare you — think of it as an AND gate with a floor at zero. It selectively activates paths: some neurons fire, some get zeroed out. This means the MLP can learn conditional patterns like "if features A and B are both present, activate feature C" — which no linear system can express regardless of how many layers you stack.


## Output: Logits and Softmax

After the final MLP, the vector at each position gets multiplied by the **unembedding matrix** (to go back to vocabulary space) and you get **logits** — a vector of unnormalized scores, one per token in the vocabulary. For a 50k vocabulary, that's 50k scores representing "how likely is each token to come next."

**Softmax** maps these logits into a probability distribution. It exponentiates each score, which amplifies differences — a score of 10 vs 8 becomes a much larger gap, and low scores collapse to near zero. The result: a clean distribution that sums to 1.

You then sample from that distribution. **Temperature** controls how peaked it is: low temperature makes the model more deterministic (heavily favoring the top token), high temperature flattens the distribution (more randomness, more creativity).

The selected token then gets embedded and fed back into the model as the next input — closing the autoregressive loop.


## Encoder vs Decoder

Now with some context we can go back at the top and look at the distictions in the architectures. The key distinction: encoders let all tokens attend to each other (bidirectional). Decoders only let previous tokens attend to the current one (causal mask). To encode means to understand. To decode means to generate.

The original 2017 architecture had both, because it was built for translation:

- **Encoder** — processes the input phrase (say, in Italian). Every token attends to every other token — no mask. The result is a fully contextualized representation of the input.
- **Decoder** — generates the output phrase (say, in English). It uses masked self-attention (only look backward) plus cross-attention to query the encoder's output at every block. So generation is conditioned on the fully encoded input.

Modern architectures split along this line (which is why the diagrams above look the way they do). BERT kept only the encoder — ideal for classification, understanding, and search. GPT kept only the decoder — purpose-built for generation. Encoder-only architectures power embedding models used in retrieval systems — that's a post for another day.


# References

- [Let's build GPT: from scratch, in code, spelled out.](https://youtu.be/kCc8FmEb1nY?si=d5c2FZJV1EbQ6cc3)
- [Visualizing transformers and attention - Talk for TNG Big Tech Day '24](https://youtu.be/KJtZARuO3JY?si=iudPcmRrikUrQfcT)
- [Transformers, the tech behind LLMs - Deep Learning Chapter 5](https://youtu.be/wjZofJX0v4M?si=xzcfvYg1fWlI2mE-)
- [Attention in transformers, step-by-step - Deep Learning Chapter 6](https://youtu.be/eMlx5fFNoYc?si=Db56fvGdgJqAz5WH)
- [How might LLMs store facts - Deep Learning Chapter 7](https://youtu.be/9-Jl0dxWQs8?si=FEzs1kySv5UCs1q9)
