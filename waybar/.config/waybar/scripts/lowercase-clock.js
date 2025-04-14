#!/usr/bin/env node

// Custom Waybar clock module that forces lowercase output
// Save this as ~/.config/waybar/scripts/lowercase-clock.js
// Make it executable with: chmod +x ~/.config/waybar/scripts/lowercase-clock.js

const formatDate = () => {
	const date = new Date();
	
	// Format the date however you want here
	// This is just an example format - adjust to your preference
	const timeStr = date.toLocaleString('en-US', {
	  weekday: 'short',
	  month: 'short',
	  day: 'numeric',
	  hour: 'numeric',
	  minute: '2-digit',
	  hour12: true
	});
	
	// Convert to lowercase before output
	const lowercaseTime = timeStr.toLowerCase();
	
	// Output in Waybar JSON format
	const output = {
	  text: lowercaseTime,
	  tooltip: date.toLocaleString(),
	  class: "clock-module"
	};
	
	console.log(JSON.stringify(output));
  };
  
  // Update the clock immediately and then every second
  formatDate();
  setInterval(formatDate, 1000);