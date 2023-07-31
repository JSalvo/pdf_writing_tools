require 'pdf_writing_tools_actions'

module PdfWritingToolsProcess
  # Dato un oggetto rappresentante il tag b html, processa ricorsivamente i suoi
  # figli cosi' da ottenere le action da applicare per la creazione del pdf
  def self.process_xml_tag_b(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties + [:bold])
    end
    actions_list
  end

  # Dato un oggetto rappresentante il tag i html, processa ricorsivamente i suoi
  # figli cosi' da ottenere le action da applicare per la creazione del pdf
  def self.process_xml_tag_i(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties + [:italic])
    end
    actions_list
  end

  # Produce la "action" che permette di disegnare nel pdf, il testo con le
  # proprieta' specificate in proprerties
  def self.process_xml_text(xml_obj, properties, size = 12, upcase = false)
    data = { text: (upcase ? xml_obj.text.upcase : xml_obj.text) + ' ', styles: properties, size: size }
    [{ action_name: :draw_formatted_text, data: [data] }]
  end

  # Produce le "actions" che permettono di disegnare nel PDF, la lista contenuta
  # nel tag ul
  def self.process_xml_tag_ul(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      if child.name == "li"
        actions_list += process_xml_obj(child, properties)
      end
    end
    actions_list
  end

  # Produce le "actions" che permettono di disegnare nel PDF, la lista contenuta
  # nel tag ol
  def self.process_xml_tag_ol(xml_obj, properties, idx_start='1')
    actions_list = []
    idx = idx_start
    xml_obj.children.each do |child|
      if child.name == "li"
        actions_list += process_xml_tag_li(child, properties, idx)
        idx = idx.next
      end
    end
    actions_list
  end

  # Produce le "actions" che permettono di disengare nel PDF, l'elemento della
  # lista indicato da li
  def self.process_xml_tag_li(xml_obj, _properties, idx=nil)
    actions_list = []
    
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, [])
    end
    
    if idx
      PdfWritingToolsActions.new_line_action + PdfWritingToolsActions.atomic_text_action(idx) + PdfWritingToolsActions.indent_action(4) + actions_list
    else 
      PdfWritingToolsActions.new_line_action + PdfWritingToolsActions.bullet_action + PdfWritingToolsActions.indent_action(4) + actions_list
    end
  end

  # Produce le "actions" che permettono di disegnare nel PDF, il contenuto
  # del tag p
  def self.process_xml_tag_p(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties)
    end
    PdfWritingToolsActions.new_line_action + actions_list
  end

  def self.process_xml_tag_h1(xml_obj, properties)
    actions_list = process_xml_text(xml_obj.child, [:bold], 16, true)
    PdfWritingToolsActions.new_line_action + actions_list + PdfWritingToolsActions.new_line_action * 2  
  end

  # Produce le actions necessarie per disegnare nel PDF un determinato
  # "tag"
  def self.process_xml_obj(xml_obj, properties)
    case xml_obj.name
    when 'text', 'b', 'i', 'ul', 'li', 'p', 'h1', 'ol'
      @process_xml_tag_table[xml_obj.name].call(xml_obj, properties)
    when 'br'
      PdfWritingToolsActions.new_line_action
    else
      [] # Non previsto
    end
  end

  @process_xml_tag_table =
  {
    'text' => method(:process_xml_text),
    'b' => method(:process_xml_tag_b),
    'i' => method(:process_xml_tag_i),
    'ul' => method(:process_xml_tag_ul),
    'ol' => method(:process_xml_tag_ol),
    'li' => method(:process_xml_tag_li),
    'p' => method(:process_xml_tag_p),
    'h1' => method(:process_xml_tag_h1)
  }
end
