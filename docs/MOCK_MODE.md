# Mock Mode & Offline Fallback Architecture

To allow offline verification and testing when backend API servers are unreachable:

1. **Local Bid Mirroring:** Placed bids are stored locally in `SharedPreferences` (`my_bids` key) so the My Bids history tab works offline.
2. **Fallback Game Rates:** When `/game-rates/` returns a network error, static fallback rates matching web values (Single 1:9, Jodi 1:90, Single Panna 1:140, Double Panna 1:280, Triple Panna 1:700, Half Sangam 1:1000, Full Sangam 1:10000) are loaded.
3. **User Profile Cache:** Cached user entity in `SharedPreferences` allows offline wallet balance rendering.
