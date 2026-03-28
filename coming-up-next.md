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

## projects
- **a local RAG**

## AI for developers
- **a (not so) deep dive into the Transformer architecture** from teh 3 blue one brown
- **BERT vs GPT** this because embeddings come up very often. Encoder vs Decoder vs the original translation. Bidirectional self attention vs causal unidirectional attention

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

## Go patterns - composition vs inheritance
- Don't export interfaces but compose them

In Go, the common rule is: accept interfaces, return concrete types.
Interfaces are usually best defined by the consumer (the orchestration service), not by the producer (repository package).
That keeps abstractions minimal and avoids “fat interface first” design.

so often (looking at you AI code completes) you get a package that looks like

```golang
type PackageInterface interface {
    Method1().
}

func (t *thisPackage) Method1() {
    ...
}

```

and maybe the package even exports a mockery or a hand drawn mock.

But that is not what we want to do. That is some OOP Java pattern disguised as go.

Examples in the wild. In go you want to export an actual implementation. Teh consumer declares the interface that it would accept and, if what you export satisfies it, then youare iin

meaning
```golang
// this is from io in the go library
type Writer interface {
	Write(p []byte) (n int, err error)
}

func Copy(dst Writer, src Reader) (written int64, err error) {
	return copyBuffer(dst, src, nil)
}

```
And the tests do...
```golang
type largeWriter struct {
	err error
}

func (w largeWriter) Write(p []byte) (int, error) {
	return len(p) + 1, w.err
}

func TestCopyLargeWriter(t *testing.T) {
	want := ErrInvalidWrite
	rb := new(Buffer)
	wb := largeWriter{}
	rb.WriteString("hello, world.")
	if _, err := Copy(wb, rb); err != want {
		t.Errorf("Copy error: got %v, want %v", err, want)
	}

	want = errors.New("largeWriterError")
	rb = new(Buffer)
	wb = largeWriter{err: want}
	rb.WriteString("hello, world.")
	if _, err := Copy(wb, rb); err != want {
		t.Errorf("Copy error: got %v, want %v", err, want)
	}
}
``

why? because then you can inject anything that respects that 
``golang
io.Copy(os.Stdout, strings.NewReader("hello"))
io.Copy(httpResponse, fileHandle)
io.Copy(gzipWriter, bytes.Buffer)
```

In other words, the interface is actually defined by the consumer, as the smallest subset of behavior it accepts. One example of this is net/http in standard library , looking at the type Handler interface.

Another is io, still in the standard library, example type Writer.


How composition is usually presented

```golang
type User struct {
	Name string
	// use only what you want where you want
	Auth
}

// every user will respect this one
func (u *User) HasFeatures() []string{
	return []string{}
}

type TrialUser struct {
	Name String
}

type Auth struct {}

func (a *Auth) GetToken() string}{
	return "a token"
}

var u User
u.GetToken()

```
But I think we can go further

## Rust traits — follow-up to the Go interfaces post
- Same composition philosophy, but Rust traits require explicit `impl` and the orphan rule constrains who can implement what for whom. Consumer-defined contracts don't work as freely — different contract ownership model, different coordination cost profile.
