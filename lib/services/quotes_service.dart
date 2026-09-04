class QuotesService {
  static const List<String> _quotes = [
    'Peace comes from within. Do not seek it without.',
    'The mind is everything. What you think, you become.',
    'Be where you are, not where you think you should be.',
    'Breathe in light, breathe out love.',
    'In stillness, the world finds its balance.',
    'Every breath is a chance to begin again.',
    'The present moment is filled with joy and happiness.',
    'Calm mind brings inner strength and self-confidence.',
    'Meditation is not evasion; it is a serene encounter with reality.',
    'The soul always knows what to do to heal itself.',
    'Silence is not empty. It is full of answers.',
    'Your calm mind is the ultimate weapon against your challenges.',
    'Within you there is a stillness and a sanctuary to which you can retreat.',
    'Do not dwell in the past, do not dream of the future.',
    'The thing about meditation is: you become more and more you.',
    'Quiet the mind, and the soul will speak.',
    'Meditation is the tongue of the soul and the language of the spirit.',
    'Nature does not hurry, yet everything is accomplished.',
    'Happiness is not something ready-made. It comes from your own actions.',
    'When you own your breath, nobody can steal your peace.',
    'Be still. Stillness reveals the infinite space within.',
    'The greatest weapon against stress is our ability to choose one thought over another.',
    'Meditation is a way for nourishing and blossoming the divinity within you.',
    'Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.',
    'In the midst of movement and chaos, keep stillness inside of you.',
    'The mind is like water. When it is turbulent, it is difficult to see. When it is calm, everything becomes clear.',
    'Practicing regular meditation can change the brain and body to help manage many health conditions.',
    'Almost everything will work again if you unplug it for a few minutes, including you.',
    'Meditation is not about stopping thoughts, but recognizing that we are more than our thoughts.',
    'A few conscious breaths can transform your entire being.',
  ];

  static String getRandomQuote() {
    final now = DateTime.now();
    final index = (now.year * 366 + now.month * 31 + now.day) % _quotes.length;
    return _quotes[index];
  }
}
