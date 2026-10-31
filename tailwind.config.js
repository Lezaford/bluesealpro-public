/** @type {import('tailwindcss').Config} */
// Semantic colour tokens are CSS variables (see application.tailwind.css) so
// every surface flips between light and dark from one place. The brand blue
// scale is unchanged from the original palette.
const token = (name) => `rgb(var(--${name}) / <alpha-value>)`;

module.exports = {
  darkMode: "class",
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/assets/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", "Inter", "ui-sans-serif", "system-ui", "-apple-system", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif"],
        mono: ["ui-monospace", "SFMono-Regular", "Menlo", "Consolas", "monospace"],
      },
      colors: {
        brand: {
          50:  "#eef5ff",
          100: "#d8e6ff",
          200: "#b3caff",
          300: "#83a6ff",
          400: "#4d7dff",
          500: "#2563eb",   // primary blue (logo/button)
          600: "#1d4ed8",
          700: "#1e40af",
          800: "#1e3a8a",
          900: "#172554"
        },
        canvas:   token("canvas"),
        surface:  token("surface"),
        raised:   token("raised"),
        line:     token("line"),
        ink:      token("ink"),
        "ink-2":  token("ink-2"),
        muted:    token("muted"),
        link:     token("link"),
      },
      boxShadow: {
        card: "0 1px 2px rgb(0 0 0 / .08), 0 8px 24px -12px rgb(0 0 0 / .35)",
        pop:  "0 12px 32px -8px rgb(0 0 0 / .45)",
      },
      keyframes: {
        "fade-up": { "0%": { opacity: 0, transform: "translateY(6px)" }, "100%": { opacity: 1, transform: "none" } },
        "pop-in":  { "0%": { opacity: 0, transform: "translateY(-4px) scale(.98)" }, "100%": { opacity: 1, transform: "none" } },
      },
      animation: {
        "fade-up": "fade-up .35s ease-out both",
        "pop-in":  "pop-in .12s ease-out both",
      },
    }
  },
  plugins: [],
};
