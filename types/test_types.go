package types

import (
	"errors"
	"testing"
	"time"
)

func TestParseDatetime(t *testing.T) {
	testCases := []struct {
		input  string
		output time.Time
		err    error
	}{
		// Successful parsing with different formats
		{"2023-11-28T12:34:56.789012 UTC", time.Date(2023, 11, 28, 12, 34, 56, 789012000, time.UTC), nil},
		{"2023-11-28 12:34:56 +0000 UTC", time.Date(2023, 11, 28, 12, 34, 56, 0, time.UTC), nil},
		// Successful parsing without timezone
		{"2023-11-28 12:34:56.789012", time.Date(2023, 11, 28, 12, 34, 56, 789012000, time.Local), nil},
		// Error cases
		{"invalid_format", time.Time{}, errors.New("parsing error")}, // Adjust error message as needed
	}

	for _, tc := range testCases {
		t.Run(tc.input, func(t *testing.T) {
			actual, err := ParseDatetime(tc.input)
			if err != nil && tc.err == nil {
				t.Errorf("Expected no error, got %v", err)
			} else if err == nil && tc.err != nil {
				t.Errorf("Expected error, got nil")
			} else if err != nil && tc.err != nil && err.Error() != tc.err.Error() {
				t.Errorf("Expected error %v, got %v", tc.err, err)
			}
			if err == nil && !actual.Equal(tc.output) {
				t.Errorf("Expected %v, got %v", tc.output, actual)
			}
		})
	}
}
