"use client";

import { useState, useEffect, useRef } from "react";
import { useOpenRouterAuth } from "@/hooks/use-openrouter-auth";

export default function ApiKeyInput() {
  const { apiKey, isAuthenticated, isLoading, error, setApiKey: saveApiKey, signOut } = useOpenRouterAuth();

  const [inputValue, setInputValue] = useState("");
  const [editing, setEditing] = useState(false);
  const [feedback, setFeedback] = useState<string | null>(null);
  const [feedbackType, setFeedbackType] = useState<"success" | "error" | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // When the component mounts and the user already has a key, show the masked key
  const [displayKey, setDisplayKey] = useState<string | null>(null);

  useEffect(() => {
    if (isAuthenticated && apiKey) {
      // Show a masked version of the key
      setDisplayKey(maskApiKey(apiKey));
    } else {
      setDisplayKey(null);
    }
  }, [isAuthenticated, apiKey]);

  useEffect(() => {
    if (editing && inputRef.current) {
      inputRef.current.focus();
    }
  }, [editing]);

  function maskApiKey(key: string): string {
    if (key.length <= 8) return key;
    return key.slice(0, 6) + "...".slice(0, Math.min(key.length - 8, 3)) + key.slice(-4);
  }

  function handleSave() {
    const key = inputValue.trim();
    if (!key) {
      setFeedback("API key cannot be empty.");
      setFeedbackType("error");
      return;
    }

    if (!key.startsWith("sk-or-")) {
      setFeedback("Invalid API key format. Use an OpenRouter key (starts with sk-or-).");
      setFeedbackType("error");
      return;
    }

    saveApiKey(key);
    setInputValue("");
    setEditing(false);
    setDisplayKey(maskApiKey(key));
    setFeedback("API key saved.");
    setFeedbackType("success");
    setTimeout(() => setFeedback(null), 3000);
  }

  function handleClear() {
    signOut();
    setDisplayKey(null);
    setInputValue("");
    setEditing(false);
    setFeedback("API key cleared.");
    setFeedbackType("success");
    setTimeout(() => setFeedback(null), 3000);
  }

  function handleKeyDown(e: React.KeyboardEvent) {
    if (e.key === "Enter") {
      handleSave();
    } else if (e.key === "Escape") {
      setEditing(false);
      setInputValue("");
      setFeedback(null);
    }
  }

  function handlePaste(e: React.ClipboardEvent<HTMLInputElement>) {
    // Allow natural paste, the input will be updated
  }

  if (isAuthenticated && !editing) {
    return (
      <div className="relative p-4 bg-accent/5 border border-accent/20 rounded-xl space-y-3">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-muted tracking-wide">API Key</p>
            <p className="text-sm text-foreground/80 font-mono mt-0.5">{displayKey}</p>
          </div>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => {
                setEditing(true);
                setInputValue("");
              }}
              className="px-3 py-1.5 text-xs tracking-wide border border-border rounded-lg hover:border-accent/40 hover:shadow-[0_0_8px_rgba(59,130,246,0.1)] transition-all cursor-pointer"
            >
              Change
            </button>
            <button
              type="button"
              onClick={handleClear}
              className="px-3 py-1.5 text-xs tracking-wide border border-border rounded-lg hover:text-red-400 hover:border-red-500/40 transition-all cursor-pointer"
            >
              Clear
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="relative p-4 bg-accent/5 border border-accent/20 rounded-xl space-y-3 shadow-[0_0_10px_rgba(59,130,246,0.1)]">
      <button
        type="button"
        onClick={() => {
          setEditing(false);
          setFeedback(null);
        }}
        className="absolute top-3 right-3 p-1 text-muted hover:text-accent transition-colors cursor-pointer"
        aria-label="Close"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <line x1="18" y1="6" x2="6" y2="18" />
          <line x1="6" y1="6" x2="18" y2="18" />
        </svg>
      </button>
      <p className="text-sm text-foreground/90 pr-6 tracking-wide">
        Enter your OpenRouter API key to generate media without signing in.
      </p>
      <div className="flex items-center gap-2">
        <input
          ref={inputRef}
          type="password"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyDown={handleKeyDown}
          onPaste={handlePaste}
          placeholder="sk-or-..."
          className="flex-1 px-3 py-2 bg-surface border border-border rounded-lg text-sm text-foreground placeholder:text-muted/50 focus:outline-none focus:border-accent/60 transition-all"
        />
        <button
          type="button"
          onClick={handleSave}
          disabled={isLoading}
          className="px-4 py-2 text-xs tracking-wide bg-accent hover:bg-accent-hover text-white rounded-lg transition-all hover:shadow-[0_0_15px_rgba(59,130,246,0.3)] disabled:opacity-50 cursor-pointer"
        >
          Save
        </button>
      </div>
      {feedback && (
        <p className={`text-xs ${feedbackType === "success" ? "text-green-400" : "text-red-400"}`}>
          {feedback}
        </p>
      )}
    </div>
  );
}