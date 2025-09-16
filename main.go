package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
)

const defaultMessage = "This page has been moved to a new location."
const defaultLink = "https://example.com"
const defaultPort = "8080"

type PageData struct {
	Message string
	Link    string
}

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func redirectHandler(w http.ResponseWriter, r *http.Request) {
	message := getEnvOrDefault("REDIRECT_MESSAGE", defaultMessage)
	link := getEnvOrDefault("REDIRECT_LINK", defaultLink)

	data := PageData{
		Message: message,
		Link:    link,
	}

	tmpl := `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Moved</title>
    <style>
        body {
            font-family: 'Courier New', Courier, monospace;
            background: white;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            max-width: 600px;
            margin: 2rem;
        }
        h1 {
            color: black;
            margin-bottom: 1rem;
            font-size: 1.5rem;
            font-weight: normal;
        }
        p {
            color: black;
            font-size: 1rem;
            line-height: 1.4;
            margin-bottom: 1rem;
        }
        .link {
            color: #0066cc;
            text-decoration: underline;
        }
        .countdown {
            color: #666;
            font-size: 0.9rem;
            margin-top: 1rem;
        }
    </style>
    <script>
        let countdown = 5;
        let countdownElement;
        
        function updateCountdown() {
            if (!countdownElement) {
                countdownElement = document.getElementById('countdown');
            }
            if (countdownElement) {
                countdownElement.textContent = countdown;
            }
            if (countdown <= 0) {
                window.location.href = '{{.Link}}';
            } else {
                countdown--;
                setTimeout(updateCountdown, 1000);
            }
        }
        
        window.onload = function() {
            updateCountdown();
        };
    </script>
</head>
<body>
    <div class="container">
        <h1>PAGE MOVED</h1>
        <p>{{.Message}}</p>
        <p>Redirecting to <a href="{{.Link}}" class="link">{{.Link}}</a> in <span id="countdown">5</span> seconds...</p>
    </div>
</body>
</html>`

	t, err := template.New("redirect").Parse(tmpl)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := t.Execute(w, data); err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
}

func main() {
	port := getEnvOrDefault("PORT", defaultPort)
	
	http.HandleFunc("/", redirectHandler)
	
	log.Printf("Server starting on port %s", port)
	log.Printf("Message: %s", getEnvOrDefault("REDIRECT_MESSAGE", defaultMessage))
	log.Printf("Link: %s", getEnvOrDefault("REDIRECT_LINK", defaultLink))
	
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}
