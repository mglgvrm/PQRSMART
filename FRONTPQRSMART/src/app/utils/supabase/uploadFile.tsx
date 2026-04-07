import { supabase } from "@/app/api/supabase";

export const uploadFile = async (file: File) => {
  const fileName = `${Date.now()}-${file.name}`;

  const { error } = await supabase.storage
    .from("pqrs-files")
    .upload(fileName, file);

  if (error) {
    console.error("Error subiendo:", error);
    return null;
  }

  const { data } = supabase.storage.from("pqrs-files").getPublicUrl(fileName);

  return data.publicUrl;
};
