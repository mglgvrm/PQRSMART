"use client";
import api from "@/app/api/api";
import { useEffect, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import Popup from "./Popup";

type FormData = {
  mediumAnswer: string;
  description: string;
  date: Date;
  answer?: string;
  category: number | "";
  requestState: {
    idRequestState: number;
  };
  dependencia: number | "";
  requestType: number | "";
  archivo: File | null;
};

export default function AddNewPqrsModal({
  onClose,
  onSave,
}: {
  onClose: () => void;
  onSave?: (data: FormData) => void;
}) {
  const [formData, setFormData] = useState<FormData>({
    mediumAnswer: "",
    description: "",
    date: new Date(),
    answer: undefined,
    requestType: "",
    dependencia: "",
    requestState: { idRequestState: 1 },
    category: "",
    archivo: null,
  });
  const [requestType, setRequest] = useState([]);
  const [dependencias, setDependencias] = useState([]);
  const [categoriasTypes, setCategorias] = useState([]);

  const [filteredCategorias, setFilteredCategorias] = useState<any[]>([]);
  const [archivo, setArchivo] = useState(null);
  const token = localStorage.getItem("token");
  const fileInputRef = useRef(null);
  const [showPopup, setShowPopup] = useState(false);
  const [error, setError] = useState("");
  const { t } = useTranslation("common");
  const [messages, setMessages] = useState<any[]>([
    {
      role: "assistant",
      content:
        "Hola 👋, soy tu asistente de PQRS. Puedo ayudarte a redactar quejas, reclamos o peticiones. ¿Qué necesitas hoy?",
    },
  ]);
  const [message, setMessage] = useState<any[]>([
    {
      role: "assistant",
      content:
        "Hola 👋, soy tu asistente de PQRS. Puedo ayudarte a redactar quejas, reclamos o peticiones. ¿Qué necesitas hoy?",
    },
  ]);
  const [input, setInput] = useState("");

  const sendMessage = async () => {
    if (!input.trim()) return;

    const newMessages = [...messages, { role: "user", content: input }];
    setMessage([...newMessages, {}]);
    console.log(newMessages);
    setInput("");
    try {
      const res = await api.post("/chat/box", {
        messages: newMessages,
      });

      const response = res.data;

      const textoLimpio = response
        .replace(/(\*\*|__|--|\*)/g, "\n") // **, __ o * → salto de línea

        .trim();

      setMessage([...newMessages, { role: "assistant", content: textoLimpio }]);
      setMessages([
        ...newMessages,
        { role: "assistant", content: textoLimpio },
      ]);
      console.log(messages);
    } catch (error) {
      console.error(error);
    }
  };
  const handleChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement
    >,
  ) => {
    const { name, value } = e.target;

    if (name === "dependencia") {
      const dependenciaId = Number(value);

      const filtered = categoriasTypes.filter(
        (cat: any) => cat.dependence.idDependence === dependenciaId,
      );

      setFilteredCategorias(filtered);

      setFormData((prev) => ({
        ...prev,
        dependencia: dependenciaId,
        category: "",
      }));
    } else {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      }));
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (archivo) {
      formData.archivo = archivo;
      console.log(archivo);
    }
    if (onSave) onSave(formData);

    console.log("Datos del usuario:", formData);
    onClose(); // Cierra el modal después de guardar
  };
  document.title = "Crear Solicitud";
  const fetchCategorias = async () => {
    try {
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.get("/category/get", {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log(response.data);
      setCategorias(response.data);
    } catch (error) {
      console.error("Error al obtener categorias:", error);
    }
  };

  const fetchRequest = async () => {
    try {
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.get("/request_type/get", {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log(response.data);
      setRequest(response.data);
    } catch (error) {
      console.error("Error al obtener Tipos de solicitudes", error);
    }
  };

  const fetchDependencias = async () => {
    try {
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.get("/dependence/get", {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log(response.data);
      setDependencias(response.data);
    } catch (error) {
      console.error("Error al obtener dependencias:", error);
    }
  };
  useEffect(() => {
    fetchCategorias();
    fetchRequest();
    fetchDependencias();
  }, []);
  const handleFileChange = (e: any) => {
    setArchivo(e.target.files[0]);
  };

  const closePopup = () => {
    setShowPopup(false);
  };
  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 gap-6 ">
      {/* Contenedor del modal */}
      <div className="w-1/2 bg-white rounded-2xl shadow-xl w-300 h-200 p-6 relative animate-fade-in">
        {/* Botón para cerrar */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg"
        >
          ✕
        </button>

        {/* Contenido del modal */}
        <h2 className="text-xl font-semibold text-gray-800 mb-4">
          {t("user.pqrs.pqrs_modal.add_pqrs_title")}
        </h2>

        <form
          onSubmit={handleSubmit}
          className="space-y-6 scrollbar-thin scrollbar-thumb-gray-300 scrollbar-track-gray-100 overflow-y-auto max-h-full"
        >
          <div className="relative">
            <select
              name="requestType"
              value={formData.requestType}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-5 pt-8 pb-4  text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            >
              <option key="" value="" disabled hidden>
                {t("user.pqrs.pqrs_modal.select_type")}
              </option>
              {requestType.map((type: any) => (
                <option key={type.idRequestType} value={type.idRequestType}>
                  {type.nameRequestType}
                </option>
              ))}
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("user.pqrs.pqrs_modal.type_label")}
            </label>
          </div>

          <div className="relative">
            <select
              name="dependencia"
              value={formData.dependencia}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-5 pt-8 pb-4  text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            >
              <option value="" disabled hidden>
                {t("user.pqrs.pqrs_modal.select_dependence")}
              </option>
              {dependencias.map((type: any) => (
                <option key={type.idDependence} value={type.idDependence}>
                  {type.nameDependence}
                </option>
              ))}
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("user.pqrs.pqrs_modal.dependencia_label")}
            </label>
          </div>

          <div className="relative">
            <select
              name="category"
              value={formData.category}
              onChange={handleChange}
              disabled={!formData.dependencia}
              className="peer w-full border border-gray-300 rounded-md px-5 pt-8 pb-4  text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            >
              <option value="" disabled hidden>
                {t("user.pqrs.pqrs_modal.select_category")}
              </option>
              {filteredCategorias.map((cat: any) => (
                <option key={cat.idCategory} value={cat.idCategory}>
                  {cat.nameCategory}
                </option>
              ))}
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("user.pqrs.pqrs_modal.category_label")}
            </label>
          </div>

          <div className="relative">
            <select
              name="mediumAnswer"
              value={formData.mediumAnswer}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-5 pt-8 pb-4 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            >
              <option value="" disabled hidden>
                {t("user.pqrs.pqrs_modal.select_mediymAnswer")}
              </option>
              <option value="correo">
                {t("user.pqrs.pqrs_modal.correo_option")}
              </option>
            </select>
            <label
              className="absolute left-3 top-3  text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("user.pqrs.pqrs_modal.medium_answer_label")}
            </label>
          </div>

          <div className="relative">
            <textarea
              name="description"
              rows={4}
              value={formData.description}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("user.pqrs.pqrs_modal.description_label")}
            </label>
          </div>

          <div className="w-full">
            <input
              type="file"
              name="file"
              ref={fileInputRef}
              onChange={handleFileChange}
              className="hidden"
              id="fileUpload"
            />

            <label
              htmlFor="fileUpload"
              className="flex items-center justify-between border border-gray-300 rounded-md px-3 py-2 cursor-pointer hover:border-green-500 transition"
            >
              <span className="text-gray-700">
                {t("user.pqrs.pqrs_modal.select_evidence")}
              </span>

              <span className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-500">
                {t("user.pqrs.pqrs_modal.file_label")}
              </span>
            </label>
          </div>

          <button
            type="submit"
            className="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition"
          >
            {t("user.pqrs.pqrs_modal.submit_button")}
          </button>
        </form>
      </div>

      <div className="w-1/2 bg-white border rounded-lg p-3 flex flex-col h-[500px] w-[400px]">
        <h3 className="font-semibold mb-2">Asistente IA 🤖</h3>

        {/* MENSAJES */}
        <div className="flex-1 overflow-y-auto space-y-2 mb-2">
          {message.map((msg, index) => (
            <div
              key={index}
              className={`p-2 rounded text-sm ${
                msg.role === "user"
                  ? "bg-green-100 text-right"
                  : "bg-gray-100 text-left"
              }`}
            >
              {msg.content}
            </div>
          ))}
        </div>

        {/* INPUT */}
        <div className="flex gap-2">
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            className="flex-1 border rounded px-2 py-1"
            placeholder="Escribe aquí..."
          />
          <button
            onClick={sendMessage}
            className="bg-green-500 text-white px-3 rounded"
          >
            Enviar
          </button>
        </div>
      </div>
      {showPopup && <Popup message={error} onClose={closePopup} />}
    </div>
  );
}
