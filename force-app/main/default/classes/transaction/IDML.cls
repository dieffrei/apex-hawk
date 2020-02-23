public interface IDML {
    Map<IEntity, DMLResultItem> dmlInsert(List<IEntity> records);
    Map<IEntity, DMLResultItem> dmlUpdate(List<IEntity> records);
    Map<IEntity, DMLResultItem> dmlDelete(List<IEntity> records);
}
