package main

import (
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"time"

	"gitee.com/ivfzhou/learning/golang/common"
)

func main() {
	http.HandleFunc("/events", sseHandler)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "sse.html")
	})
	log.Println("sse server listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func sseHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}

	write(w, "retry: 3000\n\n")
	flusher.Flush()

	price := 150.0
	eventID := 0

	lastID := r.Header.Get("Last-Event-ID")
	startSeq := 0
	if lastID != "" {
		_, _ = fmt.Sscanf(lastID, "%d", &startSeq)
		if startSeq > 0 {
			log.Println("reconnect eventID:", startSeq)
		}
	}
	eventID = startSeq

	heartbeat := time.NewTicker(15 * time.Second)
	defer heartbeat.Stop()

	priceTicker := time.NewTicker(1 * time.Second)
	defer priceTicker.Stop()

	for {
		select {
		case <-r.Context().Done():
			log.Println("Client disconnected")
			return

		case <-heartbeat.C:
			write(w, ": ping\n\n")
			flusher.Flush()

		case <-priceTicker.C:
			eventID++
			price += rand.Float64()*5 - 2.5
			if price < 0 {
				price = 150.0
			}

			write(w, "id: %d\n", eventID)
			write(w, "data: {\"price\":%.2f,\"time\":\"%s\"}\n\n", price, time.Now().Format(time.RFC3339))
			flusher.Flush()

			if eventID%10 == 0 {
				write(w, "event: announcement\n")
				write(w, "id: announcement-%d\n", eventID)
				write(w, "data: 第一行\n")
				write(w, "data: 第二行 %d\n\n", rand.Intn(10))
				flusher.Flush()
			}
		}
	}
}

func write(w io.Writer, s string, a ...any) {
	_, err := fmt.Fprintf(common.NewWriteAll(w), s, a...)
	if err != nil {
		log.Println(err)
	}
}
