export function Summary({ xp, onMap, onContinue }: { xp: number; onMap: () => void; onContinue: () => void }) {
  return (
    <main className="fade-up grid min-h-screen place-items-center p-5" style={{ background: '#FAFAF9' }}>
      <section className="w-full max-w-lg rounded-[40px] bg-white p-8 text-center shadow-xl">
        <div
          className="mx-auto grid h-20 w-20 place-items-center rounded-full text-4xl"
          style={{ background: '#FFE5B4' }}
        >
          🎉
        </div>
        <h1 className="mt-5 text-3xl font-black">Molt bé!</h1>
        <p className="mt-2 opacity-60">Has practicat valencià en una situació real.</p>

        {/* XP gained */}
        <div
          className="mt-7 rounded-3xl p-5"
          style={{ background: 'linear-gradient(135deg, #FFF7ED, #FFEDD5)' }}
        >
          <b className="text-4xl font-black" style={{ color: '#FF3B3B' }}>+10 XP</b>
          <p className="mt-1 text-sm font-bold opacity-60">Total: {xp} XP</p>
        </div>

        {/* Vocabulary */}
        <div className="mt-6 text-left">
          <h2 className="font-black text-lg">Paraules noves 🌟</h2>
          <p
            className="mt-2 rounded-2xl p-3 text-sm font-bold"
            style={{ background: '#E8EFFC', color: '#0B3785' }}
          >
            bon dia · voldria · gràcies
          </p>
          <h2 className="mt-5 font-black text-lg">A millorar 💪</h2>
          <p className="mt-2 text-sm opacity-60">Continua practicant la concordança de gènere.</p>
        </div>

        <button
          onClick={onContinue}
          id="summary-continue-btn"
          className="btn-press mt-7 w-full rounded-2xl py-3 font-extrabold text-white transition hover:opacity-90"
          style={{ background: 'linear-gradient(135deg, #0F47AF, #0B3785)' }}
        >
          Continuar
        </button>
        <button
          onClick={onMap}
          id="summary-map-btn"
          className="btn-press mt-3 font-bold"
          style={{ color: '#0F47AF' }}
        >
          Tornar al mapa
        </button>
      </section>
    </main>
  );
}
