"use client";
import { useEffect, useState } from "react";
import { Dialog } from "@headlessui/react";
import api from "@/app/api/api";

interface ResponderModalProps {
  pqrs: any;
  onClose: () => void;
  onSave: () => void;
}

export default function ResponderModal({
  pqrs,
  onClose,
  onSave,
}: ResponderModalProps) {
  const [response, setResponse] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState<{
    file: File | null;
  }>({
    file: null,
  });

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];

    if (!file) return;

    setFormData((prev) => ({
      ...prev,
      file,
    }));
  };
  useEffect(() => {
    document.title = "Responder PQRS";
  }, []);
  /*
  const handleSubmit = async () => {
    if (!response.trim())
      return alert("Por favor escribe una respuesta antes de enviar.");
    try {
      setIsSubmitting(true);
      const token = localStorage.getItem("token");
      if (!token)
        return console.error("No se encontró el token de autenticación");
      await api.patch(
        `/pqrs/${pqrs.id}`,
        {
          ...pqrs,
          answer: response,
          requestState: { idRequestState: 2 },
          idRequest: pqrs.idRequest,
          archivoAnswer: formData.file, // Incluir archivo en el guardado
        },
        {
          headers: { Authorization: `Bearer ${token}` },
        },
      );
      alert("Respuesta enviada correctamente ✅");
      onSave(); // Refresca la lista de PQRS
      onClose(); // Cierra el modal
    } catch (error) {
      console.error("Error al enviar la respuesta:", error);
      alert("Hubo un error al enviar la respuesta ❌");
    } finally {
      setIsSubmitting(false);
    }
  };*/
  const handleSubmit = async () => {
    console.log("envio: ");
    const formDataToSend = new FormData();
    const archivo = formData.file; // Incluir archivo en el guardado
    if (archivo !== null) {
      formDataToSend.append("archivo", archivo);
      console.log(archivo);
    }
    formDataToSend.append(
      "request",
      new Blob(
        [
          JSON.stringify({
            answer: response,
          }),
        ],
        {
          type: "application/json",
        },
      ),
    );
    try {
      const response = await api.put(
        `/request/update/${pqrs.idRequest}`,
        formDataToSend,
        {
          headers: {
            "Content-Type": "multipart/form-data",
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        },
      );
      console.log("Response:", response.data);
      alert("Respuesta enviada correctamente ✅");
      onSave(); // Refresca la lista de PQRS
      onClose(); // Cierra el modal
    } catch (error) {
      console.error("Error al enviar la respuesta:", error);
      alert("Hubo un error al enviar la respuesta ❌");
    } finally {
      setIsSubmitting(false);
    }
  };
  return (
    <Dialog open={true} onClose={onClose} className="relative z-50">
      <div
        className="fixed inset-0 bg-black/40 backdrop-blur-sm"
        aria-hidden="true"
      />

      <div className="fixed inset-0 flex items-center justify-center p-4">
        <Dialog.Panel className="w-full max-w-lg rounded-2xl bg-white shadow-2xl p-6">
          <Dialog.Title className="text-xl font-semibold text-gray-800 mb-4">
            Responder PQRS #{pqrs.id}
          </Dialog.Title>

          <div className="mb-4">
            <p className="text-sm text-gray-600 mb-2 font-medium">Respuesta:</p>
          </div>

          <textarea
            className="w-full h-32 border border-gray-300 rounded-lg p-3 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
            placeholder="Escribe aquí tu respuesta..."
            value={response}
            onChange={(e) => setResponse(e.target.value)}
          />

          <label>Adjuntar Evidencia (opcional)</label>
          <input
            type="file"
            className="file-input-Responder"
            id="file"
            onChange={handleFileChange} // Manejar el archivo name='archivo'
          />

          <div className="flex justify-end mt-6 gap-3">
            <button
              onClick={onClose}
              className="px-4 py-2 rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-100 transition"
            >
              Cancelar
            </button>

            <button
              onClick={handleSubmit}
              disabled={isSubmitting}
              className="px-4 py-2 rounded-lg bg-green-600 text-white hover:bg-green-700 disabled:opacity-70 transition"
            >
              {isSubmitting ? "Enviando..." : "Enviar Respuesta"}
            </button>
          </div>
        </Dialog.Panel>
      </div>
    </Dialog>
  );
}
