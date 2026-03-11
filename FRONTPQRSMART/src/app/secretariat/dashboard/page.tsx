"use client";
import withAuth from "../../utils/withAuth";
import NavbarSecretariat from "@/app/components/navbar_secretariat";

function DashboardPageSecrtetariat() {
  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <NavbarSecretariat />
      </header>
      {/* Contenido principal */}
      <main className="flex flex-col items-center text-center mt-10 px-4 max-w-3xl">
        <h2 className="text-3xl font-semibold text-gray-900 mb-4">Welcome</h2>

        <section className="bg-gray-50 rounded-2xl shadow-md p-8 w-full">
          <h3 className="text-xl font-bold text-green-700 mb-3">Mission</h3>
          <p className="text-gray-700 leading-relaxed">
            Provide effective solutions through responsive, transparent, and
            empathetic service, managing every request, complaint, claim, and
            suggestion with a commitment to continually improving our users'
            experience.
          </p>
        </section>
      </main>
    </div>
  );
}

export default withAuth(DashboardPageSecrtetariat, ["secretariat"]);
