import sync

const (
	num_iterations = 10000
)

struct St {
mut:
	n int
}

// this function gets an array of channels for `St` references
fn do_rec_calc_send(chs []chan mut St) {
	mut s := St{}
	for {
		if !(&sync.Channel(chs[0])).pop(&s) {
			break
		}
		s.n++
		(&sync.Channel(chs[1])).push(&s)
	}
}

fn test_channel_array_mut() {
	mut chs := [chan mut St{cap: 1}, chan mut St{}]
	go do_rec_calc_send(chs)
	mut t := St{
		n: 100
	}
	for _ in 0 .. num_iterations {
		(&sync.Channel(chs[0])).push(&t)
		(&sync.Channel(chs[1])).pop(&t)
	}
	(&sync.Channel(chs[0])).close()
	assert t.n == 100 + num_iterations
}
