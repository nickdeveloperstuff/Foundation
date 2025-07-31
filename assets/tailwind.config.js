module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/foundation_web/**/*.*ex"
  ],
  safelist: [
    'span-1', 'span-2', 'span-3', 'span-4', 'span-5', 'span-6',
    'span-7', 'span-8', 'span-9', 'span-10', 'span-11', 'span-12'
  ],
  theme: {
    extend: {
      spacing: {
        '1': '4px',
        '2': '8px',
        '3': '12px',
        '4': '16px',
        '5': '20px',
        '6': '24px',
        '8': '32px',
        '10': '40px',
        '12': '48px',
        '16': '64px',
        '20': '80px',
        '24': '96px'
      },
      gridTemplateColumns: {
        '12': 'repeat(12, minmax(0, 1fr))'
      }
    }
  },
  plugins: [
    require("@tailwindcss/container-queries")
  ]
}