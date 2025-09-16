package main

import (
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

func TestRedirectHandler(t *testing.T) {
	// Test with default values
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(redirectHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check if the response contains the default message
	expectedMessage := defaultMessage
	if !strings.Contains(rr.Body.String(), expectedMessage) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedMessage)
	}

	// Check if the response contains the default link
	expectedLink := defaultLink
	if !strings.Contains(rr.Body.String(), expectedLink) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedLink)
	}
}

func TestRedirectHandlerWithEnvVars(t *testing.T) {
	// Set environment variables
	os.Setenv("REDIRECT_MESSAGE", "Custom message")
	os.Setenv("REDIRECT_LINK", "https://custom.example.com")
	defer os.Unsetenv("REDIRECT_MESSAGE")
	defer os.Unsetenv("REDIRECT_LINK")

	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(redirectHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check if the response contains the custom message
	expectedMessage := "Custom message"
	if !strings.Contains(rr.Body.String(), expectedMessage) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedMessage)
	}

	// Check if the response contains the custom link
	expectedLink := "https://custom.example.com"
	if !strings.Contains(rr.Body.String(), expectedLink) {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expectedLink)
	}
}

func TestGetEnvOrDefault(t *testing.T) {
	// Test with existing environment variable
	os.Setenv("TEST_VAR", "test_value")
	defer os.Unsetenv("TEST_VAR")

	result := getEnvOrDefault("TEST_VAR", "default_value")
	if result != "test_value" {
		t.Errorf("getEnvOrDefault returned %v, want %v", result, "test_value")
	}

	// Test with non-existing environment variable
	result = getEnvOrDefault("NON_EXISTING_VAR", "default_value")
	if result != "default_value" {
		t.Errorf("getEnvOrDefault returned %v, want %v", result, "default_value")
	}
}
