# Coming Up Next

*Working list of papers and topics I want to explore. Not published to the site, but visible in the repo for interested readers.*

## Foundational Architecture Papers
- **Brooks, F. P. (1975)** - *The Mythical Man-Month: Essays on Software Engineering*
- **CAP Theorem** - always a good one as we are on the cloud
- **A review of serverless** - look back at the flavor of the mid and late 2010s
- **Transactional outbox pattern** - I used this a few times, and called it a different way. It is very nifty, so writing a paper about this one

## Modern Applications
- **Humble, J., & Farley, D. (2010)** - *Continuous Delivery: Reliable Software Releases*
- **Boehm, B. W., & Basili, V. R. (2001)** - "Software defect reduction top 10 list"

## Organizational Design
- **Kniberg, H. (2014)** - "Spotify Engineering Culture"
- **Westrum, R. (2004)** - "A typology of organisational cultures"
- **Squad HealthCheck** - Spotify, how to make Retros more incisive
- HBR 1999 decoding the DNA of the toyota production system

### One example of encoder: embedding models for a RAG

If you want to do a Retrieval Augmented Generation (HyDe too for example) you need to feed into the LLM (decoder) some of
the sources for the "Augmented" part. Now, across all of your document, how do you decide what to put in? You can use a Encoder only and embed the query. So in this case the input query is transformed into a high degree vector (e.g. 3072 for text-embedding-3-large).  You encode all of your documents (in chunks likely) and run a cosine similarity (how parallel are these vectors?).


